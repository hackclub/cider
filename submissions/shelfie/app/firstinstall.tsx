import {
  ScrollView,
  TextInput,
  View,
  Image,
  Pressable,
  Text,
  Alert,
} from "react-native";
import styles from "@/assets/styles/style";
import Octicons from '@expo/vector-icons/Octicons';
import AsyncStorage from "@react-native-async-storage/async-storage";
import { router } from "expo-router";
export default function FirstInstall() {
  async function closeFirstInstall() {
    AsyncStorage.setItem("firstinstall", "false").then(() => {
      router.replace("/login");
    });
  }
  return (
    <View
      style={{
        padding: 10,
        paddingTop: 50,
        alignItems: "center",
      }}
    >
      <Text style={{ fontSize: 20 }}>welcome to</Text>
      <Text style={{ fontSize: 42, fontWeight: "bold", color: "#37B7C3" }}>
        shelfie!
      </Text>
      <View
        style={{
          flexDirection: "column",
          gap: 50,
          margin: 50,
          alignItems: "center",
        }}
      >
        <View
          style={{
            flexDirection: "row",
            gap: 20,
          }}
        >
          <Text style={{ fontSize: 48 }}>🔭</Text>
          <Text
            style={{
              fontWeight: 300,
              fontSize: 16,
            }}
          >
            Search for books, write reviews, and share them on the explore page.
            Connect with readers and discover new favorites.
          </Text>
        </View>
        <View
          style={{
            flexDirection: "row",
            gap: 20,
          }}
        >
          <Text style={{ fontSize: 48 }}>❤️</Text>
          <Text
            style={{
              fontWeight: 300,
              fontSize: 16,
            }}
          >
            Discover 15 new books daily, tailored to your taste. Swipe right to
            like, left to pass. The app learns from your choices!
          </Text>
        </View>
        <View
          style={{
            flexDirection: "row",
            gap: 20,
          }}
        >
          <Text style={{ fontSize: 48 }}>📚</Text>
          <Text
            style={{
              fontWeight: 300,
              fontSize: 16,
            }}
          >
            Track books you want to read or have finished. Build a streak and
            share it with friends! Your library data is stored locally.{" "}
          </Text>
        </View>
      </View>
      <Pressable
        style={{
          width: "80%",
          backgroundColor: "#37B7C3",
          margin: "auto",
          alignItems: "center",
          padding: 10,
          borderRadius: 9,
        }}
        onPress={closeFirstInstall}
      >
        <Text
          style={{
            fontSize: 24,
            color: "white",
          }}
        >
          Get started!
        </Text>
      </Pressable>
    </View>
  );
}
