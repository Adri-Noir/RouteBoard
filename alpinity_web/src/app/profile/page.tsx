import ProfileDetailsSkeleton from "@/components/modules/profile/me-profile/ProfileDetailsSkeleton";
import { Suspense } from "react";
import ClientProfile from "./ClientProfile";

export default async function ProfilePage() {
  return (
    <div className="container mx-auto space-y-8 md:p-4">
      <Suspense fallback={<ProfileDetailsSkeleton />}>
        <ClientProfile />
      </Suspense>
    </div>
  );
}
