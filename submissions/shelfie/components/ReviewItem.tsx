import { View, Text, Pressable, Alert, Share } from "react-native";
import { SetStateAction, useEffect, useState } from "react";
import Octicons from "@expo/vector-icons/Octicons";
import * as SecureStore from "expo-secure-store";
import ResponsiveImage from "./ResponsiveImage";
import { APIEndpoint, Book, ReviewPropItem } from "./Types";
import * as LibraryStore from "./LibraryStore";
import { router } from "expo-router";
//import * as Sharing from "expo-sharing";
export default function ReviewItem(props: ReviewPropItem) {
  let { review, uuid, showBorder } = props;
  const dictionary: {
    [key: string]: string;
  } = {
    "0": "How would you describe this book to a friend?",
    "1": "What was your favourite part?",
    "2": "What was the most memorable takeaway from the book?",
    "3": "What did you appreciate most about the author's writing style?",
  };
  let [hasLiked, setHasLiked] = useState(review.liked.includes(uuid));
  let [disableLike, setDisableLike] = useState(false);
  let [disableShare, setDisableShare] = useState(false);
  let [likeCount, setLikeCount] = useState(review.liked.length);
  let [bookmarked, setBookmarked] = useState(false);
  let [contentArray, setContentArray] = useState<string[]>([
    review.content["0"],
    review.content["1"],
    review.content["2"],
    review.content["3"],
  ]);
  /*useEffect(() => {
    console.log('review.content')
  let localContentArray: string[] = [];
  for(var key in review.content) {
    console.log(key);
    console.log(review.content[key as keyof typeof review.content]);
    let localContentArray = contentArray;
    localContentArray[parseInt(key)] = review.content[key as keyof typeof review.content];
  }
  setContentArray(localContentArray);
  },[]);*/
  LibraryStore.getBook(review.meta.etag).then((data) => {
    setBookmarked(data !== null);
  });
  async function remotelyAddToLibrary() {
    setBookmarked((await LibraryStore.getBook(review.meta.etag)) !== null);
    await LibraryStore.storeBook(review.meta.etag, {
      title: review.meta.title,
    });
    fetch(
      `https://openlibrary.org/search.json?title=${encodeURIComponent(
        review.meta.title
      )}&fields=title,first_sentence,cover_edition_key,author_name,subject&limit=2&language=eng`
    )
      .then((response) => response.json())
      .then(async (response) => {
        if (response.docs.length > 0) {
          let book = response.docs[0];
          var bookInfo: Book = {
            title: book.title,
            authors: Object.keys(book).includes("author_name")
              ? book.author_name[0]
              : "",
            description: Object.keys(book).includes("first_sentence")
              ? book.first_sentence[0]
              : "No description available",
            etag: review.meta.etag,
            category: book.subject || [],
          };
          LibraryStore.storeBook(review.meta.etag, bookInfo);
        } else {
          Alert.alert("Error", "Could not find book");
        }
      })
      .catch((err) => {
        console.log(err);
        Alert.alert("Error", "Could not add book to library");
      });
  }
  async function likeReview() {
    setHasLiked(!review.liked.includes(uuid));
    setLikeCount(!review.liked.includes(uuid) ? likeCount + 1 : likeCount - 1);
    setDisableLike(true);
    review.liked.includes(uuid)
      ? review.liked.splice(review.liked.indexOf(uuid), 1)
      : review.liked.push(uuid);
    fetch(`https://shelfie.pidgon.com/api/likeReview`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        uuid: uuid,
        reviewId: review.uuid,
      }),
    })
      .then((res) => res.json())
      .then((data) => {
        if (data.error !== true) {
          setDisableLike(false);
        } else {
          setDisableLike(false);
          Alert.alert("Error", "Could not like review");
        }
      })
      .catch((err) => {
        setDisableLike(false);
        console.log(err);
        Alert.alert("Error", "Could not like review");
      });
  }
  return (
    <View
      style={{
        backgroundColor: "white",
        margin: 10,
        borderRadius: 9,
        width: "95%",
        alignSelf: "center",
        borderWidth: showBorder ? 1 : 0,
      }}
    >
      <View
        style={{
          padding: 10,
          shadowColor: "#37B7C3",
        }}
      >
        <Pressable
          onPress={() => {
            router.push({
              pathname: "/profile",
              params: {
                username: review.username,
              },
            });
          }}
        >
          <Text>
            <Text
              style={{
                fontSize: 18,
                fontWeight: "bold",
                color: "#37B7C3",
              }}
            >
              {review.username}
            </Text>{" "}
            read:
          </Text>
        </Pressable>
        <Text
          style={{
            fontSize: 18,
            fontWeight: "bold",
          }}
        >
          {review.meta.title}
          <Text style={{ color: "lightgrey" }}> | </Text>
          <Text
            style={{
              fontWeight: "normal",
              color: "gray",
            }}
          >
            {review.meta.authors}
          </Text>
        </Text>
        <Text style={{ fontSize: 16 }}>
          and felt{" "}
          {review.emotions
            .split(", ")
            .filter((emotion) => emotion !== "")
            .map((emotion, index) => {
              return (
                <Text style={{ color: "#37B7C3" }} key={index}>
                  {emotion}
                  {index == review.emotions.split(", ").length - 1
                    ? ""
                    : index === review.emotions.split(", ").length - 2
                    ? " and "
                    : ", "}
                </Text>
              );
            })}
        </Text>

        {review.meta.etag !== "" ? (
          <ResponsiveImage
            url={`https://covers.openlibrary.org/b/olid/${review.meta.etag}-M.jpg`}
            style={{
              width: "100%",
              height: 200,
              marginTop: 10,
              marginBottom: 10,
              borderRadius: 9,
            }}
          />
        ) : null}
        <Text>
          <View
            style={{
              flexDirection: "column",
              gap: 15,
            }}
          >
            {contentArray.map((answer: string, index: number) => {
              if (answer.trim() !== "") {
                return (
                  <View key={index}>
                    <Text
                      style={{
                        fontSize: 18,
                        fontWeight: "bold",
                      }}
                    >
                      {dictionary[index.toString()]}
                    </Text>
                    <Text>{answer}</Text>
                  </View>
                );
              }
            })}
          </View>
        </Text>
        <View
          style={{
            flexDirection: "row",
            justifyContent: "flex-end",
            gap: 15,
            margin: 5,
          }}
        >
          <Pressable
            onPress={likeReview}
            style={{
              flexDirection: "row",
              gap: 5,
            }}
            disabled={disableLike}
          >
            <Text
              style={{
                fontSize: 20,
              }}
            >
              {likeCount}
            </Text>
            <Octicons
              name={`heart${hasLiked ? "-fill" : ""}`}
              size={26}
              color={hasLiked ? "red" : "black"}
            />
          </Pressable>
        </View>
      </View>
    </View>
  );
}
