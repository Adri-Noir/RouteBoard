import { RefObject, useEffect, useState } from "react";

interface UseInteractiveMapOptions {
  mapRef: RefObject<mapboxgl.Map | null>;
  wrapperRef: RefObject<HTMLDivElement | null>;
}

export function useInteractiveMap({ mapRef, wrapperRef }: UseInteractiveMapOptions) {
  const [isInteractive, setIsInteractive] = useState(false);

  // Toggle map interactivity when isInteractive changes
  useEffect(() => {
    if (!mapRef.current) return;

    if (isInteractive) {
      mapRef.current.dragPan.enable();
      mapRef.current.scrollZoom.enable();
      mapRef.current.boxZoom.enable();
      mapRef.current.dragRotate.enable();
      mapRef.current.keyboard.enable();
      mapRef.current.doubleClickZoom.enable();
      mapRef.current.touchZoomRotate.enable();
    } else {
      mapRef.current.dragPan.disable();
      mapRef.current.scrollZoom.disable();
      mapRef.current.boxZoom.disable();
      mapRef.current.dragRotate.disable();
      mapRef.current.keyboard.disable();
      mapRef.current.doubleClickZoom.disable();
      mapRef.current.touchZoomRotate.disable();
    }

    // Re-enable controls when interactive, disable when not
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
