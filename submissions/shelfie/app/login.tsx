import { useEffect, useState } from "react";
import {
  Text,
  View,
  SafeAreaView,
  TextInput,
  TouchableWithoutFeedback,
  Keyboard,
  Alert,
  ImageBackground,
  Pressable,
} from "react-native";
import { Link, router } from "expo-router";
let gradient = require("../assets/images/homeScreen.png");
import * as SecretStore from "@/components/SecretStore";
import styles from "../assets/styles/style";
import { APIEndpoint } from "@/components/Types";

export default function Index() {
  let [changeUsername, onChangeUsername] = useState("");
  let [changePassword, onChangePassword] = useState("");
  let [isDisabled, setDisabled] = useState(false);
  useEffect(() => {
    (async () => {
      let uuid = await SecretStore.get("uuid");
      if (uuid) {
        router.replace("/home");
        console.log(uuid);
      }
    })();
  }, []);
  function Login() {
    setDisabled(true);
    fetch(`https://shelfie.pidgon.com/api/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: changeUsername,
        password: changePassword,
      }),
    })
      .then((res) => res.json())
      .then(async (data) => {
        if (data.error) {
          Alert.alert(data.message);
          setDisabled(false);
          return;
        } else {
          await SecretStore.set("uuid", data.uuid);
          await SecretStore.set("username", data.username);
          setDisabled(false);
          router.replace("/");
        }
      })
      .catch((err) => {
        Alert.alert("An error occurred. Please try again later.", JSON.stringify(err));
        setDisabled(false);
        console.log(err);
      });
  }
  return (
    <ImageBackground
      source={gradient}
      style={styles.image}
      imageStyle={{ opacity: 0.6 }}
    >
      <TouchableWithoutFeedback onPress={Keyboard.dismiss} accessible={false}>
        <SafeAreaView style={styles.container}>
          <View>
            <View
              style={{
                marginBottom: 20,
                alignItems: "center",
              }}
            >
              <View style={{ display: "flex", flexDirection: "row", gap: 10 }}>
                <Text
                  style={{
                    fontSize: 34,
                    fontWeight: "bold",
                    paddingLeft: 5,
                    paddingRight: 5,
                  }}
                >
                  shelfie
                </Text>
              </View>
            </View>
            <View>
              <TextInput
                style={styles.input}
                onChangeText={(t) => {
                  onChangeUsername(t.trim().toLowerCase());
                }}
                value={changeUsername}
                placeholder="username or email"
                keyboardType="default"
                autoCapitalize="none"
                autoComplete="off"
                spellCheck={false}
              />
              <TextInput
                style={styles.input}
                onChangeText={onChangePassword}
                value={changePassword}
                placeholder="password"
                secureTextEntry={true}
                autoCapitalize="none"
              />
              <Pressable
                style={isDisabled ? styles.disabledButton : styles.button}
                onPress={Login}
                disabled={isDisabled}
              >
                <Text style={styles.buttonText}>log in!</Text>
              </Pressable>
              <Text style={{ textAlign: "center" }}>or</Text>
              <View
                style={{
                  alignItems: "center",
                }}
              >
                <Link
                  href="/signup"
                  style={{
                    fontSize: 18,
                  }}
                >
                  sign up
                </Link>
              </View>
            </View>
          </View>
        </SafeAreaView>
      </TouchableWithoutFeedback>
    </ImageBackground>
  );
}
