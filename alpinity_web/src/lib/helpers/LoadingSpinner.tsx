"use client";
import { Loader2 } from "lucide-react";
import { PropsWithChildren } from "react";

type LoadingSpinnerProps = PropsWithChildren<{
  className?: string;
  isLoading?: boolean;
}>;

export const SmallLoadingSpinner = ({ children, isLoading }: LoadingSpinnerProps) => {
  return <>{isLoading ? <Loader2 className="animate-spin text-white" /> : children}</>;
};
