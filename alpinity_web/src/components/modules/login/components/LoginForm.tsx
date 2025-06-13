"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import useAuth from "@/lib/hooks/useAuth";
import { useForm } from "@tanstack/react-form";
import { Loader2 } from "lucide-react";
import Link from "next/link";
import { z } from "zod";

const loginSchema = z.object({
  emailOrUsername: z.string().min(1),
  password: z.string().min(1),
});

const LoginForm = () => {
  const { login, isLoginLoading, isError, error } = useAuth();

  const form = useForm({
    defaultValues: {
      emailOrUsername: "",
      password: "",
    },
    validators: {
      onMount: loginSchema,
      onChange: loginSchema,
    },
    onSubmit: (data) => {
      login({
        emailOrUsername: data.value.emailOrUsername,
        password: data.value.password,
      });
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="flex flex-col gap-6">
        <form.Field name="emailOrUsername">
          {(field) => (
            <div className="grid gap-2">
              <Label htmlFor={field.name}>Username or Email</Label>
              <Input
                id={field.name}
                name={field.name}
                type="text"
                placeholder="m@example.com"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                required
              />
            </div>
          )}
        </form.Field>
        <form.Field name="password">
          {(field) => (
            <div className="grid gap-2">
              <div className="flex items-center">
                <Label htmlFor={field.name}>Password</Label>
                <a href="#" className="ml-auto inline-block text-sm underline-offset-4 hover:underline">
                  Forgot your password?
                </a>
              </div>
              <Input
                id={field.name}
                name={field.name}
                type="password"
                value={field.state.value}
                onBlur={field.handleBlur}
                onChange={(e) => field.handleChange(e.target.value)}
                required
              />
            </div>
          )}
        </form.Field>
        <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting, isLoginLoading]}>
          {([canSubmit, isSubmitting]) => (
            <>
              <Button type="submit" className="w-full" variant="default" disabled={!canSubmit}>
                {isSubmitting || isLoginLoading ? (
                  <>
                    <Loader2 className="animate-spin" />
                  </>
                ) : (
                  "Login"
                )}
              </Button>
              {isError ? (
                <p className="text-center text-sm text-red-500">{error?.detail ?? "An error occurred"}</p>
              ) : null}
            </>
          )}
        </form.Subscribe>
      </div>
      <div className="mt-4 text-center text-sm">
        Don&apos;t have an account?{" "}
        <Link href="/register" className="underline underline-offset-4">
          Sign up
        </Link>
      </div>
    </form>
  );
};

export default LoginForm;
