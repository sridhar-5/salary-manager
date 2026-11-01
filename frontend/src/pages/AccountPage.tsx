import { Button, PasswordInput, Stack, Text, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { notifications } from "@mantine/notifications";
import { useMutation } from "@tanstack/react-query";
import { api, errorMessage, fieldErrors } from "../api/client";
import { useAuth } from "../auth/AuthContext";

export function AccountPage() {
  const { admin } = useAuth();
  const form = useForm({
    initialValues: { current_password: "", password: "", password_confirmation: "" },
    validate: {
      current_password: (value) => (value ? null : "Enter your current password"),
      password: (value) => (value.length >= 6 ? null : "Use at least 6 characters"),
      password_confirmation: (value, values) =>
        value === values.password ? null : "Passwords do not match",
    },
  });
  const save = useMutation({
    mutationFn: () => api("/api/v1/password", { method: "PATCH", body: form.values }),
    onSuccess: () => {
      form.reset();
      notifications.show({ message: "Password updated" });
    },
    onError: (error) => {
      const errors = fieldErrors(error);
      if (Object.keys(errors).length > 0) form.setErrors(errors);
      else notifications.show({ color: "red", message: errorMessage(error) });
    },
  });

  return (
    <Stack maw={480}>
      <div>
        <Title order={2}>Account</Title>
        <Text c="dimmed">
          {admin?.email} · {admin?.roles.join(", ")}
        </Text>
      </div>
      <form onSubmit={form.onSubmit(() => save.mutate())}>
        <Stack>
          <PasswordInput label="Current password" {...form.getInputProps("current_password")} />
          <PasswordInput label="New password" {...form.getInputProps("password")} />
          <PasswordInput label="Confirm new password" {...form.getInputProps("password_confirmation")} />
          <Button type="submit" loading={save.isPending}>
            Update password
          </Button>
        </Stack>
      </form>
    </Stack>
  );
}
