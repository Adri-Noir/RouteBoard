"use client";

import { ProfileAscentTypeChart } from "@/components/modules/profile/me-profile/ProfileAscentTypeChart";
import { ProfileAscentTypeTable } from "@/components/modules/profile/me-profile/ProfileAscentTypeTable";
import { ProfileAscentsTable } from "@/components/modules/profile/me-profile/ProfileAscentsTable";
import ProfileDetailsSkeleton from "@/components/modules/profile/me-profile/ProfileDetailsSkeleton";
import { ProfileGradeDistribution } from "@/components/modules/profile/me-profile/ProfileGradeDistribution";
import { ProfileRecentlyAscended } from "@/components/modules/profile/me-profile/ProfileRecentlyAscended";
import { ProfileStats } from "@/components/modules/profile/me-profile/ProfileStats";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  getApiUserRecentlyAscendedRoutesOptions,
  getApiUserUserByProfileUserIdOptions,
  getApiUserUserByProfileUserIdRecentlyAscendedRoutesOptions,
} from "@/lib/api/@tanstack/react-query.gen";
import useAuth from "@/lib/hooks/useAuth";
import { useQuery } from "@tanstack/react-query";

interface ClientProfileProps {
  userId?: string;
}

export default function ClientProfile({ userId: propUserId }: ClientProfileProps = {}) {
  const { user, isAuthenticated, isUserLoading } = useAuth();

  // Use provided userId or fall back to current user's ID
  const userId = propUserId ?? user?.id ?? "";
  const isOwnProfile = !propUserId || propUserId === user?.id;

  const {
    data: profile,
    isLoading: isProfileLoading,
    error: profileError,
  } = useQuery({
    ...getApiUserUserByProfileUserIdOptions({ path: { profileUserId: userId } }),
    enabled: !!userId && (isOwnProfile ? isAuthenticated : true),
  });

  const {
    data: recentAscents,
    isLoading: isRecentLoading,
    error: recentError,
  } = useQuery({
    ...getApiUserRecentlyAscendedRoutesOptions(),
    enabled: isAuthenticated && isOwnProfile,
  });

  const {
    data: recentAscentsOther,
    isLoading: isOtherRecentLoading,
    error: otherRecentError,
  } = useQuery({
    ...getApiUserUserByProfileUserIdRecentlyAscendedRoutesOptions({ path: { profileUserId: userId } }),
    enabled: isAuthenticated && !isOwnProfile,
  });

  if (isUserLoading || isProfileLoading || isRecentLoading || isOtherRecentLoading || !profile) {
    return <ProfileDetailsSkeleton />;
  }

  if (profileError || recentError || otherRecentError) {
    return <div className="text-destructive p-4">Error loading profile.</div>;
  }

  return (
    <div className="space-y-8 p-4">
      <ProfileStats profile={profile} />
      {isOwnProfile && recentAscents && <ProfileRecentlyAscended routes={recentAscents} />}
      {!isOwnProfile && recentAscentsOther && <ProfileRecentlyAscended routes={recentAscentsOther} />}

      {profile.routeTypeAscentCount && profile.routeTypeAscentCount.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Ascents by Route Type</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <ProfileAscentTypeTable data={profile.routeTypeAscentCount} />
            <ProfileAscentTypeChart data={profile.routeTypeAscentCount} />
          </CardContent>
        </Card>
      )}

      {profile.climbingGradeAscentCount && profile.climbingGradeAscentCount.length > 0 && (
        <ProfileGradeDistribution data={profile.climbingGradeAscentCount} />
      )}

      {/* Ascents History Table */}
      <ProfileAscentsTable userId={userId} />
    </div>
  );
}
