import { useEffect, useRef, useState } from "react";
import {
  Text,
  View,
  SafeAreaView,
  ScrollView,
  ImageBackground,
  Image,
  Pressable,
  Animated,
  PanResponder,
  Alert,
} from "react-native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
let gradient = require("../../../assets/images/homeScreen.png");
import Octicons from '@expo/vector-icons/Octicons';
import styles from "../../../assets/styles/style";
import * as SecretStore from "@/components/SecretStore";
import { APIEndpoint, Book } from "@/components/Types";
import TinderCard from "react-tinder-card";
const Stack = createNativeStackNavigator();

export default function SwipeScreen({
  navigation,
  route,
}: {
  navigation: any;
  route: any;
}) {
  let { bookData, swipeSuggestionsData, currentIndexData } = route.params;
  let [book, setBookData] = useState<Book>(bookData);
  let [swipeSuggestions, setSwipeSuggestionsData] =
    useState<any>(swipeSuggestionsData);
  let [lastBookTitle, setLastBookTitle] = useState<string>("");
  let [lastBookFeedback, setLastBookFeedback] = useState<string>("");
  let [currentIndex, setCurrentIndexData] = useState<number>(currentIndexData);
  let [nextSwipeLoading, setNextSwipeLoading] = useState<number>(0);
  useEffect(() => {
    if (currentIndexData === 1000) {
      setNextSwipeLoading(2);
    }
  }, []);
  console.log(`-------------------\n`);
  console.log(`swipeSuggestions: ${JSON.stringify(swipeSuggestions)}`);
  console.log(`currentIndex: ${currentIndex}`);
  console.log(`-------------------\n`);
  /*function swipeHandler(dir: string) {
    if (dir === "left") {
      loadNextBook("dislike");
    } else if (dir === "right") {
      loadNextBook("like");
    } else if (dir === "up") {
      loadNextBook("neutral");
    }
  }*/

  async function loadNextBook(feedback: string) {
    if (currentIndex === swipeSuggestions.length - 1) {
      let localSwipeSuggestions = swipeSuggestions;
      localSwipeSuggestions[currentIndex].title = book.title;
      localSwipeSuggestions[currentIndex].feedback = feedback;
      let swipes = swipeSuggestions;
      for (let i = 0; i < swipes.length; i++) {
        swipes[i] = JSON.stringify(swipes[i]);
      }
      setNextSwipeLoading(1);
      let uuid = await SecretStore.get("uuid");
      fetch(`https://shelfie.pidgon.com/api/saveSwipes`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          uuid: uuid,
          swipes: JSON.stringify(swipes),
        }),
      })
        .then((response) => response.json())
        .then((response) => {
          if (response.error === false) {
            setNextSwipeLoading(2);
          }
        })
        .catch((error) => {
          console.error("Error:", error);
          setNextSwipeLoading(0);
          Alert.alert("Error", "Could not save scouts.");
        });
    } else {
      console.log("loading next book");
      setNextSwipeLoading(1);
      console.log(
        "current book giving feedback:",
        JSON.stringify(swipeSuggestions[currentIndex])
      );
      console.log(
        `https://openlibrary.org/search.json?title=${encodeURIComponent(
          swipeSuggestions[currentIndex + 1].title
        )}`
      );

      let localSwipeSuggestions = swipeSuggestions;
      localSwipeSuggestions[currentIndex].title = book.title;
      localSwipeSuggestions[currentIndex].feedback = feedback;
      fetch(
        `https://openlibrary.org/search.json?title=${encodeURIComponent(
          swipeSuggestions[currentIndex + 1].title
        )}&fields=title,first_sentence,cover_edition_key,author_name,subject&limit=1&lang=en`
      )
        .then((response) => response.json())
        .then((response) => {
          setNextSwipeLoading(0);
          let nextBook = response.docs[0];
          let category = Object.keys(nextBook).includes("subject")
            ? nextBook.subject
            : [];
          category = category.slice(0, 3);

          var bookInfo: Book = {
            title: nextBook.title,
            authors: Object.keys(nextBook).includes("author_name")
              ? nextBook.author_name[0]
              : "",
            description: Object.keys(nextBook).includes("first_sentence")
              ? nextBook.first_sentence[0]
              : "No description available",
            etag: Object.keys(nextBook).includes("cover_edition_key")
              ? nextBook.cover_edition_key
              : "",
            category: category.join(", "),
          };
          setLastBookTitle(book.title);
          setLastBookFeedback(feedback === "" ? lastBookFeedback : feedback);
          setSwipeSuggestionsData(localSwipeSuggestions);
          setBookData(bookInfo);
          setCurrentIndexData(currentIndex + 1);
          /*navigation.navigate("SwipeScreen", {
            book: bookInfo,
            swipeSuggestions: swipeSuggestionsData,
            currentIndex: currentIndex+1,
          });*/
        })
        .catch((error) => {
          console.error("Error:", error);
          setNextSwipeLoading(0);
          Alert.alert("Error", "Could not load next book");
        });
    }
  }
  return (
    <ImageBackground
      source={gradient}
      style={styles.image}
      imageStyle={{ opacity: 0.6 }}
    >
      <SafeAreaView style={styles.container}>
        <>
          <Text
            style={{
              fontSize: 32,
              color: "black",
              fontWeight: "bold",
            }}
          >
            scout
          </Text>
          {nextSwipeLoading === 1 ? (
            <View
              style={{
                height: "80%",
                width: "90%",
                margin: "auto",
                backgroundColor: "#f8f8f8",
                borderColor: "white",
                borderWidth: 2,
                borderRadius: 20,
                marginBottom: 10,
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
              }}
            >
              <Text style={styles.title}>Loading...</Text>
            </View>
          ) : nextSwipeLoading === 2 ? (
            <View
              style={{
                height: "80%",
                width: "90%",
                margin: "auto",
                backgroundColor: "#f8f8f8",
                borderColor: "white",
                borderWidth: 2,
                borderRadius: 20,
                marginBottom: 10,
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
              }}
            >
              <Text
                style={{
                  fontSize: 34,
                  fontWeight: "bold",
                  textAlign: "center",
                }}
              >
                Today's scouts are done!
              </Text>
              <Text>Check back tomorrow for more.</Text>
            </View>
          ) : (
            <>
              {/*<TinderCard
                onSwipe={(dir) => swipeHandler(dir)}
                preventSwipe={["down"]}
                swipeRequirementType="velocity"
              >*/}
                <View
                  style={{
                    height: "80%",
                    width: 350,
                    margin: "auto",
                    backgroundColor: "#f8f8f8",
                    borderColor: "white",
                    borderWidth: 2,
                    borderRadius: 25,
                    marginBottom: 10,
                  }}
                >
                  <ScrollView
                    style={{
                      height: "100%",
                      width: "100%",
                    }}
                  >
                    <Text style={styles.title}>{book.title}</Text>
                    {book.etag !== "" ? (
                      <Image
                        source={{
                          uri: `https://covers.openlibrary.org/b/olid/${book.etag}-L.jpg`,
                        }}
                        style={{
                          width: "auto",
                          height: 200,
                          resizeMode: "contain",
                          margin: 10,
                          marginLeft: 0,
                          marginRight: 0,
                        }}
                      />
                    ) : null}
                    <View
                      style={{
                        margin: 20,
                        marginTop: 0,
                        flexDirection: "column",
                        gap: 20,
                      }}
                    >
                      <Text style={{ fontSize: 20 }}>{book.authors}</Text>
                      <Text style={{ fontSize: 20 }}>{book.category}</Text>
                      <Text style={{ fontSize: 20 }}>{book.description}</Text>
                    </View>
                  </ScrollView>
                </View>
              {/*</TinderCard>*/}
              <View
                style={{
                  flexDirection: "row",
                  justifyContent: "space-between",
                  width: "90%",
                }}
              >
                <Pressable
                  style={{
                    borderRadius: 50,
                    backgroundColor: "#f8f8f8",
                    borderColor: "white",
                    borderWidth: 1,
                    padding: 5,
                  }}
                  onPress={() => {
                    loadNextBook("dislike");
                  }}
                >
                  <Octicons
                    name="x-circle-fill"
                    size={34}
                    style={{
                      verticalAlign: "middle",
                      margin: 5,
                    }}
                    color={"black"}
                  />
                </Pressable>

                <Pressable
                  style={{
                    borderRadius: 50,
                    backgroundColor: "#f8f8f8",
                    borderColor: "white",
                    borderWidth: 1,
                    padding: 5,
                  }}
                  onPress={() => {
                    loadNextBook("neutral");
                  }}
                >
                  <Octicons
                    name="no-entry"
                    size={34}
                    style={{
                      verticalAlign: "middle",
                      margin: 5,
                    }}
                    color={"grey"}
                  />
                </Pressable>
                <Pressable
                  style={{
                    borderRadius: 50,
                    backgroundColor: "#f8f8f8",
                    borderColor: "white",
                    borderWidth: 2,
                    padding: 5,
                  }}
                  onPress={() => {
                    loadNextBook("like");
                  }}
                >
                  <Octicons
                    name="feed-heart"
                    size={34}
                    style={{
                      verticalAlign: "middle",
                      margin: 5,
                    }}
                    color={"red"}
                  />
                </Pressable>
              </View>
            </>
          )}
        </>
      </SafeAreaView>
    </ImageBackground>
  );
}
