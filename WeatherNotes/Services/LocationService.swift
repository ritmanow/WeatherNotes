import CoreLocation
import Foundation

/// Requests when-in-use location permission and performs a one-shot current location lookup.
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    /// One shared instance so permission / location work is not torn down while a continuation is pending (e.g. closing the add sheet).
    static let shared = LocationService()

    private let manager: CLLocationManager
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var authTimeoutTask: Task<Void, Never>?
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    private override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Returns the current coordinate, or `nil` if permission is denied/restricted, lookup fails, or `timeoutSeconds` elapses.
    func requestCoordinateOrNil(timeoutSeconds: TimeInterval = 15) async -> CLLocationCoordinate2D? {
        guard await ensureWhenInUseAccess() else { return nil }
        return await fetchCoordinateOnce(timeoutSeconds: timeoutSeconds)
    }

    private func ensureWhenInUseAccess() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            let status = await waitForAuthorizationResolution()
            return status == .authorizedWhenInUse || status == .authorizedAlways
        @unknown default:
            return false
        }
    }

    private func fetchCoordinateOnce(timeoutSeconds: TimeInterval) async -> CLLocationCoordinate2D? {
        await withTaskGroup(of: CLLocationCoordinate2D?.self) { group in
            group.addTask { [weak self] in
                guard let self else { return nil }
                return await self.singleLocationLookup()
            }
            group.addTask {
                let nanoseconds = UInt64(timeoutSeconds * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
                return nil
            }
            for await value in group {
                group.cancelAll()
                return value
            }
            return nil
        }
    }

    private func singleLocationLookup() async -> CLLocationCoordinate2D? {
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>) in
                locationContinuation = continuation
                manager.requestLocation()
            }
        } onCancel: { [weak self] in
            Task { @MainActor in
                self?.resolveLocationContinuation(with: nil)
            }
        }
    }

    private func resolveLocationContinuation(with value: CLLocationCoordinate2D?) {
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: value)
        }
    }

    /// Waits until authorization leaves `.notDetermined` (user choice) or times out.
    private func waitForAuthorizationResolution() async -> CLAuthorizationStatus {
        await withCheckedContinuation { (continuation: CheckedContinuation<CLAuthorizationStatus, Never>) in
            authContinuation = continuation
            manager.requestWhenInUseAuthorization()

            authTimeoutTask?.cancel()
            authTimeoutTask = Task { @MainActor in
                let nanoseconds = UInt64(120 * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
                resumeAuthContinuationIfNeeded(returning: manager.authorizationStatus)
            }
        }
    }

    private func resumeAuthContinuationIfNeeded(returning status: CLAuthorizationStatus) {
        guard let continuation = authContinuation else { return }
        authContinuation = nil
        authTimeoutTask?.cancel()
        authTimeoutTask = nil
        continuation.resume(returning: status)
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            // iOS can deliver this callback while still `.notDetermined`; resuming then leaks the
            // continuation (never see the final Allow/Deny). Only resolve once the user decided.
            guard status != .notDetermined else { return }
            resumeAuthContinuationIfNeeded(returning: status)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            let coordinate = locations.last.map(\.coordinate)
            resolveLocationContinuation(with: coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            resolveLocationContinuation(with: nil)
        }
    }
}
