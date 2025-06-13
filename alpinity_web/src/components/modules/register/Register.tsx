import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import RegisterForm from "./components/RegisterForm";

const Register = () => {
  return (
    <div className="flex min-h-[calc(100vh-64px)] w-full flex-col items-center justify-center">
      <div className={"flex w-full max-w-[500px] flex-col gap-6 px-4"}>
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl">Register</CardTitle>
            <CardDescription>Create your account by filling the information below</CardDescription>
          </CardHeader>
          <CardContent>
            <RegisterForm />
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Register;
