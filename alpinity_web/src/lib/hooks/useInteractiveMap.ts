import { RefObject, useEffect, useState } from "react";

interface UseInteractiveMapOptions {
  mapRef: RefObject<mapboxgl.Map | null>;
  wrapperRef: RefObject<HTMLDivElement | null>;
}

export function useInteractiveMap({ mapRef, wrapperRef }: UseInteractiveMapOptions) {
  const [isInteractive, setIsInteractive] = useState(false);

  // Toggle map interactivity when isInteractive changes or when the map instance is initialized
  useEffect(() => {
    const mapInstance = mapRef.current;
    if (!mapInstance) return;

    if (isInteractive) {
      mapInstance.dragPan.enable();
      mapInstance.scrollZoom.enable();
      mapInstance.boxZoom.enable();
      mapInstance.dragRotate.enable();
      mapInstance.keyboard.enable();
      mapInstance.doubleClickZoom.enable();
      mapInstance.touchZoomRotate.enable();
    } else {
      mapInstance.dragPan.disable();
      mapInstance.scrollZoom.disable();
      mapInstance.boxZoom.disable();
      mapInstance.dragRotate.disable();
      mapInstance.keyboard.disable();
      mapInstance.doubleClickZoom.disable();
      mapInstance.touchZoomRotate.disable();
    }

    // Update control styles
    const controls = document.querySelectorAll(".mapboxgl-ctrl");
    controls.forEach((control) => {
      if (isInteractive) {
        control.classList.remove("pointer-events-none", "opacity-50");
      } else {
        control.classList.add("pointer-events-none", "opacity-50");
      }
    });
  }, [isInteractive, mapRef]);

  // Add click outside handler
  useEffect(() => {
    if (!isInteractive) return;

    const handleClickOutside = (event: MouseEvent) => {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target as Node)) {
        setIsInteractive(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isInteractive, wrapperRef]);

  const handleActivateMap = () => {
    setIsInteractive(true);
  };

  const handleDeactivateMap = () => {
    setIsInteractive(false);
  };

  return {
    isInteractive,
    handleActivateMap,
    handleDeactivateMap,
  };
}
