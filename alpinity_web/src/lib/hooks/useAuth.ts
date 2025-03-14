"use client";
import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient, useSuspenseQuery } from "@tanstack/react-query";
import {
  postApiAuthenticationLoginMutation,
  postApiAuthenticationMeOptions,
  postApiAuthenticationMeQueryKey,
} from "../api/@tanstack/react-query.gen";
import { usePathname, useRouter } from "next/navigation";
import { client } from "../api/client.gen";
import Cookies from "js-cookie";

const getToken = () => {
  return Cookies.get("token") ?? null;
};

client.interceptors.request.use((request) => {
  const token = getToken();

  if (token) {
    request.headers.set("Authorization", `Bearer ${token}`);
  }

  return request;
});

const useAuth = () => {
  const router = useRouter();
  const pathname = usePathname();
  const queryClient = useQueryClient();

  const [token, setToken] = useState<string | null>(getToken());

  const { data: user, isLoading: isUserLoading } = useQuery({
    ...postApiAuthenticationMeOptions(),
    enabled: !!token,
  });

  const {
    mutate: loginMutation,
    isPending: isLoginLoading,
    isError,
    error,
  } = useMutation({
    ...postApiAuthenticationLoginMutation(),
    onSuccess: (data) => {
      if (data.token) {
        setToken(data.token);
        Cookies.set("token", data.token);
        router.push("/");
      }
    },
  });

  const login = ({ emailOrUsername, password }: { emailOrUsername: string; password: string }) => {
    loginMutation({
      body: {
        emailOrUsername,
        password,
      },
    });
  };

  const logout = () => {
    setToken(null);
    Cookies.remove("token");
    queryClient.invalidateQueries();
    queryClient.clear();
    router.push("/login");
  };

  const isAuthenticated = !!user;

  useEffect(() => {
    if (user && pathname === "/login") {
      router.push("/");
    }
  }, [user, pathname, router]);

  console.log(isUserLoading);

  return {
    token,
    login,
    isLoginLoading,
    isError,
    error,
    logout,
    isAuthenticated,
    user,
    isUserLoading,
  };
};

export default useAuth;
