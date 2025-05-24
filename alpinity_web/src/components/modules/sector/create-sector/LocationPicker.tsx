"use client";

import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { useInteractiveMap } from "@/lib/hooks/useInteractiveMap";
import { MapPin, RotateCcw } from "lucide-react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import { useEffect, useRef, useState } from "react";

// Set Mapbox access token
mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN || "";

interface LocationPickerProps {
  latitude: number;
  longitude: number;
  onLocationChange: (latitude: number, longitude: number) => void;
  cragLocation?: { latitude: number; longitude: number };
}

const LocationPicker = ({ latitude, longitude, onLocationChange, cragLocation }: LocationPickerProps) => {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapWrapperRef = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markerRef = useRef<mapboxgl.Marker | null>(null);
  const [isMapReady, setIsMapReady] = useState(false);

  const { isInteractive, handleActivateMap, handleDeactivateMap } = useInteractiveMap({
    mapRef: map,
    wrapperRef: mapWrapperRef,
  });

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || map.current) return;

    // Use crag location as center if available, otherwise use current coordinates or default
    const centerLat = cragLocation?.latitude || latitude || 45.815;
    const centerLng = cragLocation?.longitude || longitude || 15.9819;

    const newMap = new mapboxgl.Map({
      container: mapContainer.current,
      style: "mapbox://styles/mapbox/outdoors-v12",
      center: [centerLng, centerLat],
      zoom: cragLocation ? 14 : 10,
    });

    map.current = newMap;

    // Add navigation controls
    newMap.addControl(new mapboxgl.NavigationControl(), "top-right");

    // Disable all interaction initially
    newMap.dragPan.disable();
    newMap.scrollZoom.disable();
    newMap.boxZoom.disable();
    newMap.dragRotate.disable();
    newMap.keyboard.disable();
    newMap.doubleClickZoom.disable();
    newMap.touchZoomRotate.disable();

    newMap.on("load", () => {
      setIsMapReady(true);
    });

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, []); // Only initialize once

  // Handle click events separately
  useEffect(() => {
    if (!map.current) return;

    const handleMapClick = (e: mapboxgl.MapMouseEvent) => {
      if (!isInteractive) return;
      const { lng, lat } = e.lngLat;
      onLocationChange(lat, lng);
    };

    map.current.on("click", handleMapClick);

    return () => {
      if (map.current) {
        map.current.off("click", handleMapClick);
      }
    };
  }, [isInteractive, onLocationChange]);

  // Add/update sector marker
  useEffect(() => {
    if (!map.current || !isMapReady) return;

    // Remove existing marker
    if (markerRef.current) {
      markerRef.current.remove();
      markerRef.current = null;
    }

    // Only add marker if we have valid coordinates
    if (latitude !== 0 || longitude !== 0) {
      // Create marker element
      const el = document.createElement("div");
      el.className = "marker";
      el.style.width = "25px";
      el.style.height = "25px";
      el.style.backgroundSize = "100%";
      el.style.backgroundImage = `url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%232563eb' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z'/%3E%3Ccircle cx='12' cy='10' r='3'/%3E%3C/svg%3E")`;

      // Add marker
      markerRef.current = new mapboxgl.Marker(el, { draggable: isInteractive })
        .setLngLat([longitude, latitude])
        .addTo(map.current);
    }
  }, [latitude, longitude, isMapReady, isInteractive]);

  // Handle marker drag separately
  useEffect(() => {
    if (!markerRef.current || !isInteractive) return;

    const handleDragEnd = () => {
      if (!markerRef.current) return;
      const lngLat = markerRef.current.getLngLat();
      onLocationChange(lngLat.lat, lngLat.lng);
    };

    markerRef.current.on("dragend", handleDragEnd);

    return () => {
      if (markerRef.current) {
        markerRef.current.off("dragend", handleDragEnd);
      }
    };
  }, [isInteractive, onLocationChange]);

  const handleResetToCenter = () => {
    if (!map.current || !cragLocation) return;

    // Reset to crag location
    onLocationChange(cragLocation.latitude, cragLocation.longitude);

    // Center map on crag location
    map.current.flyTo({
      center: [cragLocation.longitude, cragLocation.latitude],
      zoom: 14,
    });
  };

  const hasValidLocation = latitude !== 0 || longitude !== 0;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <Label className="flex items-center gap-2">
          <MapPin className="h-4 w-4" />
          Location *
        </Label>
        {cragLocation && (
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleResetToCenter}
            className="flex items-center gap-2"
          >
            <RotateCcw className="h-3 w-3" />
            Reset to Crag
          </Button>
        )}
      </div>

      <div className="relative space-y-2" ref={mapWrapperRef}>
        <div ref={mapContainer} className="bg-muted h-[300px] overflow-hidden rounded-md border" />

        {!isInteractive && (
          <div
            onClick={handleActivateMap}
            className="absolute inset-0 flex cursor-pointer items-center justify-center rounded-md bg-black/40 transition-opacity"
          >
            <div className="bg-background/90 rounded-md px-4 py-2 shadow-md">
              <p className="text-foreground font-medium">Click to select location</p>
            </div>
          </div>
        )}

        {isInteractive && (
          <button
            onClick={handleDeactivateMap}
            className="bg-background/90 absolute top-2 right-14 z-10 rounded-md px-2 py-1 text-xs"
          >
            Exit
          </button>
        )}
      </div>

      <div className="text-muted-foreground text-sm">
        {hasValidLocation ? (
          <p>{isInteractive && "Click on the map to change location"}</p>
        ) : (
          <p>Click on the map to select a location for this sector</p>
        )}
      </div>
    </div>
  );
};

export default LocationPicker;
