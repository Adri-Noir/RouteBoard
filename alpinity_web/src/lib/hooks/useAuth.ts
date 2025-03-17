"use client";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import Cookies from "js-cookie";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { postApiAuthenticationLoginMutation, postApiAuthenticationMeOptions } from "../api/@tanstack/react-query.gen";
import { client } from "../api/client.gen";

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
    retry: false,
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
        queryClient.invalidateQueries();
        queryClient.clear();
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
