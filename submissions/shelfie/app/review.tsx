import {
  ScrollView,
  TextInput,
  View,
  Image,
  Pressable,
  Text,
  Alert,
  Keyboard,
} from "react-native";
import styles from "@/assets/styles/style";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useEffect, useState } from "react";
import * as SecretStore from "@/components/SecretStore";
import { APIEndpoint, Book } from "@/components/Types";
import { Link, router, useLocalSearchParams } from "expo-router";
import RNPickerSelect from "react-native-picker-select";
import Octicons from '@expo/vector-icons/Octicons';
export default function ReviewModal() {
  const params = useLocalSearchParams();
  let { bookObject } = params;
  let book: Book =
    bookObject !== undefined ? JSON.parse(bookObject as string) : "{}";
  let [emotions, setEmotions] = useState<any>([]);
  let [disableSubmit, setDisableSubmit] = useState<boolean>(false);
  let [reviewContent, setReviewContent] = useState<string[]>(["", "", "", ""]);
  let [username, setUsername] = useState<string>("");
  let [uuid, setUUID] = useState<string>("");
  async function submitReview() {
    setDisableSubmit(true);
    let reviewContentBody: { [key: number]: string } = {
      0: "",
      1: "",
      2: "",
      3: "",
    };
    let allEmpty = true;
    for (let i = 0; i < reviewContent.length; i++) {
      reviewContentBody[i] =
        reviewContent[i] === undefined ? "" : reviewContent[i].trim();
      if (reviewContent[i] !== "") {
        allEmpty = false;
      }
    }
    if (allEmpty) {
      setDisableSubmit(false);
      Alert.alert("Please answer at least one question.");
      return;
    }
    fetch(`https://shelfie.pidgon.com/api/addReview`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        content: reviewContentBody,
        emotions: emotions.join(", "),
        book: book,
        uuid: uuid,
        username: username,
      }),
    })
      .then((res) => {
        return res.json();
      })
      .then((data) => {
        if (data.error) {
          setDisableSubmit(false);
          Alert.alert(data.message);
        } else {
          Alert.alert(data.message);
          router.dismiss();
        }
      })
      .catch((err) => {
        setDisableSubmit(false);
        Alert.alert("An error occurred. Please try again later.");
        console.log(err);
      });
  }
  useEffect(() => {
    (async () => {
      let uuid = await SecretStore.get("uuid");
      let user = await SecretStore.get("username");
      if (user !== null) {
        setUsername(user);
      }
      if (uuid !== null) {
        setUUID(uuid);
      }
    })();
  });
  const isPresented = router.canGoBack();
  return (
    <View>
      <KeyboardAwareScrollView>
        <View>
          <View>
            <View>
              {(book as Book).etag !== "" ? (
                <Image
                  source={{
                    uri: `https://covers.openlibrary.org/b/olid/${
                      (book as Book).etag
                    }-M.jpg`,
                  }}
                  style={{
                    width: "100%",
                    height: 175,
                    borderTopLeftRadius: 9,
                    borderTopRightRadius: 9,
                    resizeMode: "cover",
                  }}
                />
              ) : null}
              <View
                style={{
                  padding: 10,
                }}
              >
                <View
                  style={{
                    flexDirection: "row",
                    justifyContent: "space-between",
                    gap: 5,
                    width: "100%",
                    margin: "auto",
                  }}
                >
                  <View>
                    <Text
                      style={{
                        fontSize: 24,
                        fontWeight: "bold",
                      }}
                    >
                      {(book as Book).title}
                    </Text>
                    <Text
                      style={{
                        paddingBottom: 5,
                        paddingTop: 5,
                        color: "grey",
                      }}
                    >
                      {username}'s review
                    </Text>
                  </View>
                  <View style={{
                    flexDirection: "row",
                    gap: 10
                  }}>
                    <Pressable
                      style={{
                        backgroundColor: disableSubmit ? "grey" : "black",
                        padding: 10,
                        borderRadius: 9,
                        height: 50,
                        justifyContent: "center",
                      }}
                      onPress={submitReview}
                      disabled={disableSubmit}
                    >
                      <Text
                        style={{
                          color: "white",
                          fontSize: 20,
                          verticalAlign: "middle",
                        }}
                      >
                        {disableSubmit ? "Posting..." : "Post!"}
                      </Text>
                    </Pressable>
                    <Pressable
                      style={{
                        backgroundColor: disableSubmit ? "grey" : "black",
                        padding: 10,
                        borderRadius: 9,
                        height: 50,
                        justifyContent: "center",
                      }}
                      onPress={()=>{
                        router.dismiss();
                      }}
                      disabled={disableSubmit}
                    >
                      <Text
                        style={{
                          justifyContent: "center",
                        }}
                      >
                        <Octicons
                          name="x"
                          color={"white"}
                          size={34}
                        />
                      </Text>
                    </Pressable>
                  </View>
                </View>
              </View>
            </View>
            <View
              style={{
                justifyContent: "center",
                padding: 10,
                gap: 10,
              }}
            >
              <Text style={{ paddingLeft: 10, paddingRight: 10, fontSize: 18 }}>
                After reading this book, I felt{" "}
              </Text>
              <View
                style={{
                  display: "flex",
                  flexDirection: "row",
                  padding: 10,
                  marginBottom: 20,
                }}
              >
                <Text style={{ fontSize: 18 }}>
                  <RNPickerSelect
                    onValueChange={(value) => {
                      setEmotions([value, emotions[1], emotions[2]]);
                    }}
                    items={[
                      { label: "happy", value: "happy" },
                      { label: "sad", value: "sad" },
                      { label: "excited", value: "excited" },
                      { label: "angry", value: "angry" },
                      { label: "confused", value: "confused" },
                      { label: "inspired", value: "inspired" },
                      { label: "curious", value: "curious" },
                      { label: "nostalgic", value: "nostalgic" },
                      { label: "hopeful", value: "hopeful" },
                      { label: "anxious", value: "anxious" },
                      { label: "frustrated", value: "frustrated" },
                      { label: "content", value: "content" },
                      { label: "surprised", value: "surprised" },
                      { label: "relieved", value: "relieved" },
                      { label: "disappointed", value: "disappointed" },
                      { label: "empathetic", value: "empathetic" },
                      { label: "peaceful", value: "peaceful" },
                      { label: "motivated", value: "motivated" },
                      { label: "amused", value: "amused" },
                      { label: "reflective", value: "reflective" },
                    ]}
                    value={emotions[0]}
                    placeholder={{ label: "emotion", value: "" }}
                    style={{
                      inputIOS: {
                        fontSize: 16,
                        borderRadius: 9,
                        backgroundColor: "white",
                        borderWidth: 2,
                        padding: 5,
                      },
                    }}
                  />
                  <Text>, </Text>
                  <RNPickerSelect
                    onValueChange={(value) => {
                      setEmotions([emotions[0], value, emotions[2]]);
                    }}
                    items={[
                      { label: "happy", value: "happy" },
                      { label: "sad", value: "sad" },
                      { label: "excited", value: "excited" },
                      { label: "angry", value: "angry" },
                      { label: "confused", value: "confused" },
                      { label: "inspired", value: "inspired" },
                      { label: "curious", value: "curious" },
                      { label: "nostalgic", value: "nostalgic" },
                      { label: "hopeful", value: "hopeful" },
                      { label: "anxious", value: "anxious" },
                      { label: "frustrated", value: "frustrated" },
                      { label: "content", value: "content" },
                      { label: "surprised", value: "surprised" },
                      { label: "relieved", value: "relieved" },
                      { label: "disappointed", value: "disappointed" },
                      { label: "empathetic", value: "empathetic" },
                      { label: "peaceful", value: "peaceful" },
                      { label: "motivated", value: "motivated" },
                      { label: "amused", value: "amused" },
                      { label: "reflective", value: "reflective" },
                    ]}
                    value={emotions[1]}
                    placeholder={{ label: "emotion", value: "" }}
                    style={{
                      inputIOS: {
                        fontSize: 16,
                        borderRadius: 9,
                        backgroundColor: "white",
                        borderWidth: 2,
                        padding: 5,
                      },
                    }}
                  />
                  <Text>, and </Text>
                  <RNPickerSelect
                    onValueChange={(value) => {
                      setEmotions([emotions[0], emotions[1], value]);
                    }}
                    items={[
                      { label: "happy", value: "happy" },
                      { label: "sad", value: "sad" },
                      { label: "excited", value: "excited" },
                      { label: "angry", value: "angry" },
                      { label: "confused", value: "confused" },
                      { label: "inspired", value: "inspired" },
                      { label: "curious", value: "curious" },
                      { label: "nostalgic", value: "nostalgic" },
                      { label: "hopeful", value: "hopeful" },
                      { label: "anxious", value: "anxious" },
                      { label: "frustrated", value: "frustrated" },
                      { label: "content", value: "content" },
                      { label: "surprised", value: "surprised" },
                      { label: "relieved", value: "relieved" },
                      { label: "disappointed", value: "disappointed" },
                      { label: "empathetic", value: "empathetic" },
                      { label: "peaceful", value: "peaceful" },
                      { label: "motivated", value: "motivated" },
                      { label: "amused", value: "amused" },
                      { label: "reflective", value: "reflective" },
                    ]}
                    value={emotions[2]}
                    placeholder={{ label: "emotion", value: "" }}
                    style={{
                      inputIOS: {
                        fontSize: 16,
                        borderRadius: 9,
                        backgroundColor: "white",
                        borderWidth: 2,
                        padding: 5,
                      },
                    }}
                  />
                </Text>
                 
              </View>
              <View style={{ margin: 10, justifyContent: "center", gap: 10 }}>
                <View>
                  <Text>The following are four questions about the book.</Text>
                  <Text> You can answer any of them.</Text>
                </View>
                <Text style={{ fontSize: 18 }}>
                  How would you describe this book to a friend?
                </Text>
                <TextInput
                  style={styles.reviewContentInput}
                  placeholder="I would describe this book as..."
                  onChangeText={(text) => {
                    setReviewContent([
                      text,
                      reviewContent[1],
                      reviewContent[2],
                      reviewContent[3],
                    ]);
                  }}
                  defaultValue={reviewContent[0]}
                  keyboardType="default"
                  autoCapitalize="none"
                  multiline={true}
                  numberOfLines={2}
                />
                <Text style={{ fontSize: 18 }}>
                  What was your favourite part?
                </Text>
                <TextInput
                  style={styles.reviewContentInput}
                  placeholder="My favourite part was..."
                  onChangeText={(text) => {
                    setReviewContent([
                      reviewContent[0],
                      text,
                      reviewContent[2],
                      reviewContent[3],
                    ]);
                  }}
                  defaultValue={reviewContent[1]}
                  keyboardType="default"
                  autoCapitalize="none"
                  multiline={true}
                  numberOfLines={2}
                />
                <Text style={{ fontSize: 18 }}>
                  What was the most memorable takeaway from the book?
                </Text>
                <TextInput
                  style={styles.reviewContentInput}
                  placeholder="The most memorable takeaway was..."
                  onChangeText={(text) => {
                    setReviewContent([
                      reviewContent[0],
                      reviewContent[1],
                      text,
                      reviewContent[3],
                    ]);
                  }}
                  defaultValue={reviewContent[2]}
                  keyboardType="default"
                  autoCapitalize="none"
                  multiline={true}
                  numberOfLines={2}
                />
                <Text style={{ fontSize: 18 }}>
                  What did you appreciate most about the author's writing style?
                </Text>
                <TextInput
                  style={styles.reviewContentInput}
                  placeholder="Something I appreciated about the author's writing style was..."
                  onChangeText={(text) => {
                    setReviewContent([
                      reviewContent[0],
                      reviewContent[1],
                      reviewContent[2],
                      text,
                    ]);
                  }}
                  defaultValue={reviewContent[3]}
                  keyboardType="default"
                  autoCapitalize="none"
                  multiline={true}
                  numberOfLines={2}
                />
              </View>
            </View>
          </View>
        </View>
      </KeyboardAwareScrollView>
    </View>
  );
}
