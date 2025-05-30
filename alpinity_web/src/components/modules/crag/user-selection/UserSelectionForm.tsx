"use client";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import {
  getApiCragByIdUsersOptions,
  getApiCragByIdUsersQueryKey,
  getApiUserAllOptions,
  putApiCragByIdUsersMutation,
} from "@/lib/api/@tanstack/react-query.gen";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { useForm } from "@tanstack/react-form";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ChevronLeft, ChevronRight, Loader2, Search, Users, X } from "lucide-react";
import { useEffect, useMemo, useState } from "react";

interface UserSelectionFormProps {
  cragId: string;
  onSuccess?: () => void;
  onCancel?: () => void;
}

const UserSelectionForm = ({ cragId, onSuccess, onCancel }: UserSelectionFormProps) => {
  const queryClient = useQueryClient();
  const [selectedUserIds, setSelectedUserIds] = useState<Set<string>>(new Set());
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(20);

  const debouncedSearchQuery = useDebounce(searchQuery, 300);

  const {
    data: usersResponse,
    isLoading: isLoadingAllUsers,
    error: allUsersError,
    refetch: refetchAllUsers,
  } = useQuery({
    ...getApiUserAllOptions({
      query: {
        ...(debouncedSearchQuery.trim() && { search: debouncedSearchQuery.trim() }),
        page: currentPage,
        pageSize: pageSize,
      },
    }),
    staleTime: debouncedSearchQuery.trim() ? 30 * 1000 : 5 * 60 * 1000, // 30 seconds for search, 5 minutes for all
    gcTime: 10 * 60 * 1000, // 10 minutes
  });

  const allUsers = useMemo(() => usersResponse?.users || [], [usersResponse]);
  const totalUsers = usersResponse?.totalCount || 0;
  const totalPages = Math.ceil(totalUsers / pageSize);
  const hasNextPage = currentPage < totalPages;
  const hasPrevPage = currentPage > 1;

  const {
    data: cragUsers = [],
    isLoading: isLoadingCragUsers,
    error: cragUsersError,
    refetch: refetchCragUsers,
  } = useQuery({
    ...getApiCragByIdUsersOptions({ path: { id: cragId } }),
    staleTime: 1 * 60 * 1000, // 1 minute
    gcTime: 5 * 60 * 1000, // 5 minutes
  });

  const {
    mutate: updateCragUsers,
    isPending: isUpdating,
    isError: isUpdateError,
    error: updateError,
    reset: resetMutation,
  } = useMutation({
    ...putApiCragByIdUsersMutation(),
    onMutate: async (variables) => {
      await queryClient.cancelQueries({
        queryKey: getApiCragByIdUsersQueryKey({ path: { id: cragId } }),
      });

      const previousCragUsers = queryClient.getQueryData(getApiCragByIdUsersQueryKey({ path: { id: cragId } }));

      if (variables.body?.userIds && allUsers.length > 0) {
        const optimisticUsers = allUsers.filter((user) => variables.body?.userIds?.includes(user.id || ""));
        queryClient.setQueryData(getApiCragByIdUsersQueryKey({ path: { id: cragId } }), optimisticUsers);
      }

      return { previousCragUsers };
    },
    onError: (err, variables, context) => {
      if (context?.previousCragUsers) {
        queryClient.setQueryData(getApiCragByIdUsersQueryKey({ path: { id: cragId } }), context.previousCragUsers);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: getApiCragByIdUsersQueryKey({ path: { id: cragId } }),
      });
      onSuccess?.();
    },
    onSettled: () => {
      queryClient.invalidateQueries({
        queryKey: getApiCragByIdUsersQueryKey({ path: { id: cragId } }),
      });
    },
  });

  useEffect(() => {
    if (cragUsers.length > 0) {
      const cragUserIds = new Set(cragUsers.map((user) => user.id).filter(Boolean) as string[]);
      setSelectedUserIds(cragUserIds);
    }
  }, [cragUsers]);

  useEffect(() => {
    setCurrentPage(0);
  }, [debouncedSearchQuery, pageSize]);

  const form = useForm({
    defaultValues: {
      userIds: [] as string[],
    },
    onSubmit: () => {
      const userIds = Array.from(selectedUserIds);
      updateCragUsers({
        path: { id: cragId },
        body: { userIds },
      });
    },
  });

  const handleUserToggle = (userId: string, checked: boolean) => {
    setSelectedUserIds((prev) => {
      const newSet = new Set(prev);
      if (checked) {
        newSet.add(userId);
      } else {
        newSet.delete(userId);
      }
      return newSet;
    });
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  const isLoading = isLoadingAllUsers || isLoadingCragUsers;

  const hasError = allUsersError || cragUsersError;

  const userDisplayData = useMemo(() => {
    return allUsers.map((user) => ({
      ...user,
      isSelected: selectedUserIds.has(user.id || ""),
      displayName: user.username || `${user.firstName || ""} ${user.lastName || ""}`.trim() || "Unknown User",
    }));
  }, [allUsers, selectedUserIds]);

  const handleRetry = async () => {
    resetMutation();
    if (allUsersError) {
      await refetchAllUsers();
    }
    if (cragUsersError) {
      await refetchCragUsers();
    }
  };

  if (hasError) {
    return (
      <div className="space-y-4">
        <div className="border-destructive/20 bg-destructive/10 rounded-md border p-4">
          <p className="text-destructive text-sm">
            Failed to load users. Please try again.
            {allUsersError && <span className="mt-1 block">All users: {allUsersError.message}</span>}
            {cragUsersError && <span className="mt-1 block">Crag users: {cragUsersError.message}</span>}
          </p>
        </div>
        <div className="flex justify-end space-x-3">
          <Button type="button" variant="outline" onClick={handleRetry}>
            Retry
          </Button>
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Close
            </Button>
          )}
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="relative">
        <Search className="text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2" />
        <Input
          type="text"
          placeholder="Search users..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pr-10 pl-10"
        />
        {searchQuery && (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            className="absolute top-1/2 right-1 h-7 w-7 -translate-y-1/2 p-0"
            onClick={() => setSearchQuery("")}
          >
            <X className="h-4 w-4" />
          </Button>
        )}
      </div>

      {/* Header with user count and bulk actions */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <Users className="text-muted-foreground h-5 w-5" />
          {isLoading ? (
            <Skeleton className="h-4 w-48" />
          ) : (
            <span className="text-muted-foreground text-sm">
              {selectedUserIds.size} of {allUsers.length} users selected
              {debouncedSearchQuery && ` (filtered by "${debouncedSearchQuery}")`}
            </span>
          )}
        </div>
      </div>

      {/* User list */}
      <div className="max-h-96 space-y-3 overflow-y-auto rounded-md border p-4">
        {isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center space-x-3">
                <Skeleton className="h-4 w-4" />
                <Skeleton className="h-4 w-48" />
              </div>
            ))}
          </div>
        ) : userDisplayData.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <Users className="text-muted-foreground/50 h-12 w-12" />
            <p className="text-muted-foreground mt-2 text-sm">No users found</p>
          </div>
        ) : (
          userDisplayData.map((user) => (
            <div key={user.id} className="flex items-center space-x-3">
              <Checkbox
                id={`user-${user.id}`}
                checked={user.isSelected}
                onCheckedChange={(checked) => handleUserToggle(user.id || "", checked === true)}
              />
              <Label
                htmlFor={`user-${user.id}`}
                className="flex-1 cursor-pointer text-sm leading-none font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                <div className="flex flex-col">
                  <span>{user.displayName}</span>
                  {user.username && user.displayName !== user.username && (
                    <span className="text-muted-foreground text-xs">@{user.username}</span>
                  )}
                </div>
              </Label>
            </div>
          ))
        )}
      </div>

      {/* Pagination controls */}
      {(totalPages > 1 || isLoading) && (
        <div className="flex items-center justify-between border-t pt-4">
          <div className="flex items-center space-x-2">
            {isLoading ? (
              <Skeleton className="h-4 w-48" />
            ) : (
              <span className="text-muted-foreground text-sm">
                Page {currentPage + 1} of {totalPages} ({totalUsers} total users)
              </span>
            )}
          </div>
          <div className="flex items-center space-x-2">
            <Select
              value={pageSize.toString()}
              onValueChange={(value) => setPageSize(Number(value))}
              disabled={isLoading}
            >
              <SelectTrigger className="w-20">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="10">10</SelectItem>
                <SelectItem value="20">20</SelectItem>
                <SelectItem value="50">50</SelectItem>
                <SelectItem value="100">100</SelectItem>
              </SelectContent>
            </Select>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(currentPage - 1)}
              disabled={!hasPrevPage || isLoading}
            >
              <ChevronLeft className="h-4 w-4" />
              Previous
            </Button>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(currentPage + 1)}
              disabled={!hasNextPage || isLoading}
            >
              Next
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}

      {/* Error display */}
      {isUpdateError && (
        <div className="border-destructive/20 bg-destructive/10 rounded-md border p-4">
          <p className="text-destructive text-sm">
            {updateError instanceof Error ? updateError.message : "Failed to update crag users. Please try again."}
          </p>
        </div>
      )}

      {/* Action buttons */}
      <div className="flex justify-end space-x-3 pt-4">
        {onCancel && (
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        )}
        <Button type="submit" disabled={isUpdating}>
          {isUpdating && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          Save Changes
        </Button>
      </div>
    </form>
  );
};

export default UserSelectionForm;
