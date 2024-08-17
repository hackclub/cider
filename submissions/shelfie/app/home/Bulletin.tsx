import { useCallback, useEffect, useState } from "react";
import {
  Text,
  View,
  SafeAreaView,
  TextInput,
  ScrollView,
  TouchableWithoutFeedback,
  Keyboard,
  ImageBackground,
  Pressable,
  RefreshControl,
} from "react-native";
import { Link, router } from "expo-router";
let gradient = require("../../assets/images/homeScreen.png");
import * as SecretStore from "@/components/SecretStore";
import Octicons from '@expo/vector-icons/Octicons';
import { Review } from "@/components/Types";
import styles from "../../assets/styles/style";
import ReviewItem from "../../components/ReviewItem";
import { APIEndpoint } from "@/components/Types";
export default function Bulletin() {
  let [searchQuery, setSearchQuery] = useState<string>("");
  let [searchMode, setSearchMode] = useState<number>(1);
  let [cancelSearch, setCancelSearch] = useState<boolean>(false);
  let [myISBNs, setMyISBNs] = useState<string[]>([]);
  let [userUUID, setUserUUID] = useState<any>();
  let [searchResults, setSearchResults] = useState<Review[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    searchHandler(true);
  }, []);

  useEffect(() => {
    searchBooks();
  }, []);
  async function searchHandler(refresh = false) {
    if (searchMode === 0) {
      searchUsers(refresh);
    } else {
      searchBooks(refresh);
    }
  }

  async function searchUsers(refresh = false) {
    if (searchQuery.trim() === "") {
      return;
    }
    setSearchResults([]);
    fetch(`https://shelfie.pidgon.com/api/getUsers`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        query: searchQuery,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.users.length === 0) {
          setSearchResults([
            {
              content: "",
              meta: {
                title: "No users found :(",
                authors: "",
                etag: "404shelfieerror",
              },
              username: "",
              uuid: "",
              liked: [],
              emotions: ""
            },
          ]);
          if (refresh) {
            setRefreshing(false);
          }
          return;
        }
        let reviewResults: Review[] = [];
        data.users.map((review: any) => {
          var reviewData: Review = {
            content: review.reviewCount,
            meta: {
              title: review.username,
              authors: "",
              etag: "shelfieuser",
            },
            username: review.username,
            uuid: review.uuid,
            liked: [],
            emotions: ""
          };
          reviewResults.push(reviewData);
        });
        setSearchResults(reviewResults);
        if (refresh) {
          setRefreshing(false);
        }
      })
      .catch((e) => {
        console.log(e);
        setSearchResults([
          {
            content: "Connect to the internet to search for users.",
            meta: {
              title: "You're offline",
              authors: "",
              etag: "404shelfieerror",
            },
            username: "",
            uuid: "",
            liked: [],
            emotions: ""
          },
        ]);
        if (refresh) {
          setRefreshing(false);
        }
      });
  }
  async function searchBooks(refresh = false) {
    let uuid = await SecretStore.get("uuid");
    setUserUUID(uuid);
    setSearchResults([]);
    fetch(`https://shelfie.pidgon.com/api/getReviews`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        uuid: uuid,
        query: searchQuery,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.reviews.length === 0) {
          setSearchResults([
            {
              content:
                searchQuery === ""
                  ? "Write one of your own from the search page!"
                  : "",
              meta: {
                title:
                  searchQuery === ""
                    ? "No reviews yet!"
                    : "No reviews found :(",
                authors: "",
                etag: "404shelfieerror",
              },
              username: "",
              uuid: "",
              liked: [],
              emotions: "",
            },
          ]);
          if (refresh) {
            setRefreshing(false);
          }
          return;
        }
        let reviewResults: Review[] = [];
        data.reviews.map((review: any) => {
          var reviewData: Review = {
            content: review.content,
            meta: {
              title: review.meta.title,
              authors: review.meta.authors || "",
              etag: review.meta.etag || "",
            },
            username: review.username,
            uuid: review.uuid,
            liked: review.liked,
            emotions: review.emotions
          };
          reviewResults.push(reviewData);
        });
        setSearchResults(reviewResults.reverse());
        if (refresh) {
          setRefreshing(false);
        }
      })
      .catch((e) => {
        console.log(e);
        setSearchResults([
          {
            content: "Connect to the internet to search for reviews.",
            meta: {
              title: "You're offline",
              authors: "",
              etag: "404shelfieerror",
            },
            username: "",
            uuid: "",
            liked: [],
            emotions: ""
          },
        ]);
        if (refresh) {
          setRefreshing(false);
        }
      });
  }

  return (
    <ImageBackground
      source={gradient}
      style={styles.image}
      imageStyle={{ opacity: 0.6 }}
    >
      <ScrollView
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <TouchableWithoutFeedback onPress={Keyboard.dismiss} accessible={false}>
          <SafeAreaView style={styles.container}>
            <View>
                <Pressable
                  onPress={() => {
                    setSearchQuery("");
                    searchBooks();
                  }}
                >
                  <Text style={styles.title}>explore</Text>
                </Pressable>
              <View
                style={{
                  flexDirection: "row",
                  marginTop: 10,
                  margin: "auto",
                  width: "100%",
                  backgroundColor: "white",
                  borderRadius: 9,
                  shadowColor: "#37B7C3",
                  shadowRadius: 20,
                  shadowOffset: {
                    width: 0,
                    height: 0,
                  },
                  shadowOpacity: 0.5,
                }}
              >
                <Pressable
                  style={{
                    borderRadius: 9,
                    borderBottomRightRadius: 0,
                    borderTopRightRadius: 0,
                    padding: 10,
                    backgroundColor: "white",
                  }}
                  onPress={() => {
                    if (searchMode === 1) {
                      searchBooks();
                      setSearchMode(0);
                    } else setSearchMode(searchMode === 0 ? 1 : 0);
                  }}
                >
                  {searchMode === 0 ? (
                    <Octicons
                      name="mention"
                      size={24}
                      style={{
                        verticalAlign: "middle",
                        marginTop: 2,
                      }}
                      color={"black"}
                    />
                  ) : (
                    <Octicons
                      name="pencil"
                      size={24}
                      style={{
                        verticalAlign: "middle",
                        margin: 2,
                        marginRight: 1.5,
                        marginLeft: 1,
                        marginBottom: 0,
                      }}
                      color={"black"}
                    />
                  )}
                </Pressable>
                <TextInput
                  style={styles.exploreInput}
                  onSubmitEditing={() => {
                    setCancelSearch(true);
                    searchHandler();
                  }}
                  placeholder={`Search for a ${
                    searchMode === 0 ? "user" : "book review"
                  }!`}
                  onChangeText={(text) => {
                    setSearchQuery(text);
                    if (text.trim() === "") {
                      searchHandler();
                    } else {
                      setCancelSearch(false);
                      setSearchQuery(text);
                    }
                  }}
                  value={searchQuery}
                />
                <Pressable
                  style={{
                    borderRadius: 9,
                    borderBottomLeftRadius: 0,
                    borderTopLeftRadius: 0,
                    padding: 10,
                    backgroundColor: "white",
                  }}
                  onPress={() => {
                    if (cancelSearch) {
                      setSearchQuery("");
                      searchHandler();
                      setCancelSearch(false);
                    } else {
                      setCancelSearch(true);
                      searchHandler();
                    }
                  }}
                >
                  {cancelSearch ? (
                    <Octicons
                      name="x"
                      size={24}
                      style={{
                        verticalAlign: "middle",
                        margin: 4,
                        marginBottom: 0,
                        marginTop: 2,
                      }}
                      color={"black"}
                    />
                  ) : (
                    <Octicons
                      name="search"
                      size={24}
                      style={{
                        verticalAlign: "middle",
                        margin: 2,
                      }}
                      color={"black"}
                    />
                  )}
                </Pressable>
              </View>
              <View
                style={{
                  alignItems: "center",
                  justifyContent: "center",
                  width: "90%",
                }}
              >
                {searchResults.length > 0 ? (
                  searchResults.map((review: Review, index: number) =>
                    review.meta.etag !== "404shelfieerror" ? (
                      review.meta.etag === "shelfieuser" ? (
                        <View
                          style={{
                            backgroundColor: "white",
                            borderRadius: 9,
                            width: 325,
                            marginTop: 10,
                            margin: "auto",
                          }}
                          key={index}
                        >
                          <View
                            style={{
                              padding: 10,
                              shadowColor: "#37B7C3",
                            }}
                          >
                            <Text
                              style={{
                                fontSize: 17,
                                fontWeight: "bold",
                                color: "#37B7C3",
                              }}
                            >
                              {review.username}
                            </Text>
                            <View
                              style={{
                                flexDirection: "row",
                                gap: 5,
                                justifyContent: "space-between",
                              }}
                            >
                              <View
                                style={{
                                  flexDirection: "column",
                                  gap: 5,
                                  alignItems: "center",
                                  justifyContent: "center",
                                  width: "100%",
                                }}
                              >
                                <Text
                                  style={{ fontWeight: "bold", fontSize: 24 }}
                                >
                                  {review.content}
                                </Text>
                                <Text>
                                  review
                                  {parseInt(review.content) !== 1 ? "s" : ""}
                                </Text>
                              </View>
                            </View>
                            <Pressable
                              style={{
                                flexDirection: "row",
                                gap: 5,
                                padding: 5,
                                paddingTop: 10,
                                margin: "auto",
                                justifyContent: "center",
                              }}
                              onPress={() => {
                                router.push({
                                  pathname: "/profile",
                                  params: {
                                    username: review.username,
                                  },
                                });
                              }}
                            >
                              <Octicons
                                name="pencil"
                                size={20}
                                style={{
                                  verticalAlign: "middle",
                                }}
                                color={"#37B7C3"}
                              />
                              <Text style={{ color: "#37B7C3" }}>
                                View Profile
                              </Text>
                            </Pressable>
                          </View>
                        </View>
                      ) : (
                        <ReviewItem
                          review={review}
                          key={index}
                          uuid={userUUID}
                          showBorder={false}
                        />
                      )
                    ) : (
                      <View
                        style={{
                          margin: 10,
                          marginTop: 50,
                          borderRadius: 9,
                          width: 325,
                          alignItems: "center",
                        }}
                        key={0}
                      >
                        <Text
                          style={{
                            fontSize: 20,
                            fontWeight: "bold",
                          }}
                        >
                          {review.meta.title}
                        </Text>
                        <Text> {review.content}</Text>
                      </View>
                    )
                  )
                ) : (
                  <View
                    style={{
                      margin: 10,
                      marginTop: 50,
                      borderRadius: 9,
                      width: 325,
                      alignItems: "center",
                    }}
                  >
                    <Text style={{ fontSize: 20, fontWeight: "bold" }}>
                      Loading...
                    </Text>
                  </View>
                )}
              </View>
            </View>
          </SafeAreaView>
        </TouchableWithoutFeedback>
      </ScrollView>
    </ImageBackground>
  );
}
