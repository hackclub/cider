import AsyncStorage from "@react-native-async-storage/async-storage";
import { useEffect, useState } from "react";
import { Pressable, Text, View } from "react-native";
import ResponsiveImage from "./ResponsiveImage";
import { router } from "expo-router";
import Octicons from '@expo/vector-icons/Octicons';
export default function LibraryItem(props: any) {
  let [title, setTitle] = useState<string>("");
  let [authors, setAuthors] = useState<string>("");
  let [description, setDescription] = useState<string>("");
  let [fullBookData, setFullBookData] = useState<object>({})
  async function loadData() {
    let book = await AsyncStorage.getItem(`@shelfie:${props.etag}`);
    let bookObject = book ? JSON.parse(book) : null;
    setFullBookData(bookObject)
    setTitle(bookObject.title);
    setAuthors(bookObject.authors);
    setDescription(bookObject.description);
  }
  useEffect(() => {
    loadData();
  }, []);
  return (
    <View
      style={{
        backgroundColor: "white",
        margin: 10,
        borderRadius: 9,
        width: "80%",
      }}
    >
      <ResponsiveImage
        url={`https://covers.openlibrary.org/b/olid/${props.etag}-M.jpg`}
        style={{
          width: 325,
          height: 150,
          borderTopLeftRadius: 9,
          borderTopRightRadius: 9,
        }}
      />
      <View
        style={{
          padding: 10,
          shadowColor: "#37B7C3",
        }}
      >
        <Text
          style={{
            fontSize: 20,
            fontWeight: "bold",
          }}
        >
          {title}
        </Text>
        <Text
          style={{
            fontFamily: "Menlo",
            textTransform: "uppercase",
            paddingBottom: 5,
            paddingTop: 5,
          }}
        >
          {authors}
        </Text>
        <Text>{description}</Text>
        <Pressable
          style={{
            flexDirection: "row",
            justifyContent: "center",
            gap: 5,
            margin: 10,
          }}
          onPress={() =>
            router.push({
              pathname: "/review",
              params: {
                bookObject: JSON.stringify(fullBookData),
              },
            })
          }
        >
          <Octicons
            name="pencil"
            size={20}
            style={{
              verticalAlign: "middle",
              marginTop: 2,
            }}
            color={"#37B7C3"}
          />
          <Text
            style={{
              fontSize: 20,
              color: "#37B7C3",
            }}
          >
            review
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
