import { Alert, Button, Center, Paper, PasswordInput, Stack, Text, TextInput, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { Navigate } from "react-router";
import { errorMessage, fieldErrors } from "../api/client";
import { useAuth } from "../auth/AuthContext";

export function LoginPage() {
  const { admin, loading, login } = useAuth();
  const form = useForm({
    initialValues: { email: "", password: "" },
    validate: {
      email: (value) => (value.includes("@") ? null : "Enter a valid email"),
      password: (value) => (value ? null : "Enter your password"),
    },
  });

  if (!loading && admin) return <Navigate to="/directory" replace />;

  return (
    <Center mih="100vh" p="md">
      <Paper withBorder shadow="sm" p="xl" w={420}>
        <Stack>
          <div>
            <Title order={2}>Salary Manager</Title>
            <Text c="dimmed" mt={4}>
              Sign in to review and maintain compensation.
            </Text>
          </div>
          {import.meta.env.DEV && (
            <Alert variant="light">
              Development admin: admin@example.com / password
            </Alert>
          )}
          <form
            onSubmit={form.onSubmit(async (values) => {
              try {
                await login(values.email, values.password);
              } catch (error) {
                const errors = fieldErrors(error);
                if (Object.keys(errors).length > 0) form.setErrors(errors);
                else form.setFieldError("password", errorMessage(error));
              }
            })}
          >
            <Stack>
              <TextInput label="Email" autoComplete="username" {...form.getInputProps("email")} />
              <PasswordInput label="Password" autoComplete="current-password" {...form.getInputProps("password")} />
              <Button type="submit" loading={form.submitting}>
                Sign in
              </Button>
            </Stack>
          </form>
        </Stack>
      </Paper>
    </Center>
  );
}
