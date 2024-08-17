import { useEffect } from "react";
import { View } from "react-native";
import { router } from "expo-router";
import * as SecretStore from "@/components/SecretStore";
import AsyncStorage from "@react-native-async-storage/async-storage";

export default function Index() {
  useEffect(() => {
    async function prepare() {
      let firstUse = await AsyncStorage.getItem("firstinstall");
      if (firstUse === null) {
        router.push("/firstinstall");
      } else {
        let uuid = await SecretStore.get("uuid");
        if (uuid) {
          console.log("app ready");
          router.replace("/home");
          console.log(uuid);
        } else {
          console.log("app ready");
          router.replace("/login");
        }
      }
    }

    prepare();
  }, []);
  return <View></View>;
}
