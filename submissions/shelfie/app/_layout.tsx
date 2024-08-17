import { Stack } from "expo-router";
import { Alert } from 'react-native';
export default function RootLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: {
          backgroundColor: "#fff",
        },
      }}
    >
      <Stack.Screen
        name="review"
        options={{
          presentation: "modal"
        }}
      />
      <Stack.Screen
        name="profile"
        options={{
          presentation: "modal"
        }}
      />
      <Stack.Screen
        name="firstinstall"
        options={{
          presentation: "modal",
          gestureEnabled: false
        }}
      />
      <Stack.Screen name="index" />
      <Stack.Screen name="login" />
      <Stack.Screen name="signup" />
      <Stack.Screen name="home/index" options={{
        animation: "fade"
      }}/>
    </Stack>
  );
}