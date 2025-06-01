import ProfileDetailsSkeleton from "@/components/modules/profile/me-profile/ProfileDetailsSkeleton";
import { Suspense } from "react";
import ClientProfile from "../ClientProfile";

interface ProfilePageProps {
  params: Promise<{
    userId: string;
  }>;
}

export default async function ProfilePage({ params }: ProfilePageProps) {
  const { userId } = await params;

  return (
    <div className="container mx-auto space-y-8 md:p-4">
      <Suspense fallback={<ProfileDetailsSkeleton />}>
        <ClientProfile userId={userId} />
      </Suspense>
    </div>
  );
}
