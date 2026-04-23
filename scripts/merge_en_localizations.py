#!/usr/bin/env python3
"""Merge English (en) string units into Localizable.xcstrings for all uk entries."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XC = ROOT / "WeatherNotes" / "Localizable.xcstrings"

EN: dict[str, str] = {
    "%lld/%lld": "%1$lld/%2$lld",
    "add_note.error.generic": "Something went wrong. Please try again.",
    "add_note.error.save_failed": "Couldn't save the note. Please try again.",
    "add_note.error.weather_fallback": "Couldn't fetch weather.",
    "add_note.field.activity_label": "What did you do?",
    "add_note.field.note.accessibility": "Note",
    "add_note.field.note.placeholder": "e.g. jog, commute, walk in the park…",
    "add_note.info.body.prefix": "Weather data for ",
    "add_note.info.body.suffix": " will be fetched and saved with the note.",
    "add_note.info.grid.humidity_pressure": "Humidity and pressure",
    "add_note.info.grid.temperature_conditions": "Temperature and conditions",
    "add_note.info.grid.visibility_clouds": "Visibility and cloud cover",
    "add_note.info.grid.wind": "Wind speed and direction",
    "add_note.info.title": "Automatic weather capture",
    "add_note.loading": "Fetching weather and saving…",
    "add_note.location.highlight.current": "your current location",
    "add_note.location.highlight.kyiv": "Kyiv, Ukraine",
    "add_note.save_flow.weather_timeout": "The weather service isn't responding. Please try again.",
    "add_note.tips.activity": "Describe your activity in more detail",
    "add_note.tips.capture": "Weather is captured when you save",
    "add_note.tips.storage": "Notes are stored on your device",
    "add_note.tips.title": "Tips",
    "add_note.title": "New note",
    "add_note.weather_source.current_location": "Your geolocation will be used",
    "add_note.weather_source.fallback_kyiv": "Geolocation unavailable; using Kyiv.",
    "add_note.weather_source.substring.geolocation": "geolocation",
    "add_note.weather_source.substring.kyiv": "Kyiv",
    "common.accessibility.back": "Back",
    "common.action.save": "Save",
    "common.relative.today": "Today",
    "common.relative.yesterday": "Yesterday",
    "note_detail.coordinates.latitude": "Latitude",
    "note_detail.coordinates.longitude": "Longitude",
    "note_detail.coordinates.title": "Location coordinates",
    "note_detail.hero.feels_like_format": "Feels like %lld°",
    "note_detail.metric.clouds": "Cloud cover",
    "note_detail.metric.humidity": "Humidity",
    "note_detail.metric.pressure": "Pressure",
    "note_detail.metric.pressure.unit": " hPa",
    "note_detail.metric.visibility": "Visibility",
    "note_detail.metric.visibility.unit": " km",
    "note_detail.title": "Note details",
    "note_detail.wind.direction_label": "Direction",
    "note_detail.wind.speed.unit": "m/s",
    "note_detail.wind.speed_label": "Speed",
    "note_detail.wind.subtitle": "Speed and direction",
    "note_detail.wind.title": "Wind",
    "note_detail.wind_compass.accessibility": "Wind direction",
    "notes_list.action.add.accessibility": "Add note",
    "notes_list.count.note.few": "notes",
    "notes_list.count.note.many": "notes",
    "notes_list.count.note.one": "note",
    "notes_list.empty.body": "Tap the “+” button in the top-right corner to create a note with weather.",
    "notes_list.empty.title": "No notes yet",
    "notes_list.title": "Weather notes",
    "preview.seed.location_display": "Test city (preview)",
    "preview.seed.note_text": "Preview sample note — sunny walk",
    "preview.seed.weather_description": "clear sky",
    "theme.accessibility.dark": "Theme: dark",
    "theme.accessibility.light": "Theme: light",
    "theme.accessibility.system": "Theme: system",
    "weather_service.error.decoding_failed": "Couldn't read the weather response.",
    "weather_service.error.http_status_format": "Weather request failed (HTTP %lld).",
    "weather_service.error.invalid_response": "The server returned an unexpected response.",
    "weather_service.error.invalid_url": "Couldn't build the weather request.",
    "weather_service.error.missing_api_key": "OpenWeather API key is not configured.",
    "weather_service.error.missing_payload": "The response doesn't include weather data.",
    "weather_service.error.network.cancelled": "The request was cancelled.",
    "weather_service.error.network.connection_lost": "The network connection was lost.",
    "weather_service.error.network.generic": "Network error. Check your connection and try again.",
    "weather_service.error.network.host_not_found": "Couldn't reach the weather server.",
    "weather_service.error.network.offline": "No internet connection.",
    "weather_service.error.network.secure_connection_failed": "Couldn't establish a secure connection.",
    "weather_service.error.network.timeout": "The network request timed out.",
    "wind.octant.e": "E",
    "wind.octant.n": "N",
    "wind.octant.ne": "NE",
    "wind.octant.nw": "NW",
    "wind.octant.s": "S",
    "wind.octant.se": "SE",
    "wind.octant.sw": "SW",
    "wind.octant.w": "W",
}


def main() -> None:
    data = json.loads(XC.read_text(encoding="utf-8"))
    strings = data["strings"]
    missing: list[str] = []
    for key, node in strings.items():
        if not isinstance(node, dict):
            continue
        loc = node.get("localizations")
        if not loc or "uk" not in loc:
            continue
        uk_unit = loc["uk"].get("stringUnit") or {}
        uk_val = uk_unit.get("value")
        if uk_val is None:
            continue
        en_val = EN.get(key)
        if en_val is None:
            missing.append(key)
            continue
        loc["en"] = {
            "stringUnit": {
                "state": "translated",
                "value": en_val,
            }
        }
        node["localizations"] = loc
    if missing:
        raise SystemExit(f"Missing EN strings for keys: {missing}")
    XC.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Wrote", XC, "with en localizations.")


if __name__ == "__main__":
    main()
