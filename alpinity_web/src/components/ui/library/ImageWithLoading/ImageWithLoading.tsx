"use client";

import Image, { ImageProps } from "next/image";
import { useState } from "react";

interface ImageWithLoadingProps extends ImageProps {
  alt: string;
  containerClassName?: string;
  loadingSize?: "tiny" | "small" | "medium" | "large";
}

const loadingSizeToClassName = {
  tiny: "h-6 w-6",
  small: "h-10 w-10",
  medium: "h-20 w-20",
  large: "h-40 w-40",
};

const loadingSizeToBorderWidth = {
  tiny: "border-2",
  small: "border-4",
  medium: "border-6",
  large: "border-8",
};

const ImageWithLoading = ({
  alt,
  src,
  containerClassName,
  className,
  onLoad,
  loadingSize = "small",
  ...props
}: ImageWithLoadingProps) => {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className={`relative overflow-hidden ${containerClassName}`}>
      {isLoading && (
        <div className="absolute inset-0 z-10 flex items-center justify-center">
          <div
            className={`border-primary ${loadingSizeToClassName[loadingSize]} animate-spin rounded-full ${loadingSizeToBorderWidth[loadingSize]}
            border-t-transparent`}
          ></div>
        </div>
      )}
      <Image
        src={src}
        alt={alt}
        className={`object-contain ${className}`}
        onLoad={(e) => {
          setIsLoading(false);
          if (onLoad) {
            onLoad(e);
          }
        }}
        {...props}
      />
    </div>
  );
};

export default ImageWithLoading;
