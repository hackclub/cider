import { View, Text, Pressable } from "react-native";
import ResponsiveImage from "./ResponsiveImage";
import AddToShelf from "./AddToShelf";
import { router } from "expo-router";
import Octicons from "@expo/vector-icons/Octicons";
export default function SearchItem(props: any) {
  let { book } = props;
  return (
    <View
      style={{
        backgroundColor: "white",
        margin: 10,
        borderRadius: 9,
        width: "80%",
        alignSelf: "center",
      }}
    >
      {book.etag !== "" ? (
        <ResponsiveImage
          url={`https://covers.openlibrary.org/b/olid/${book.etag}-M.jpg`}
          style={{
            width: "100%",
            height: 150,
            margin: "auto",
            borderTopLeftRadius: 9,
            borderTopRightRadius: 9,
          }}
        />
      ) : null}
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
          {book.title}
        </Text>
        <Text
          style={{
            fontFamily: "Menlo",
            textTransform: "uppercase",
            paddingBottom: 5,
            paddingTop: 5,
          }}
        >
          {book.authors}
        </Text>
        <Text>{book.description}</Text>
      </View>
      <View
        style={{
          flexDirection: "row",
          justifyContent: "space-between",
          gap: 5,
          width: "100%",
          borderBottomLeftRadius: 9,
          borderBottomRightRadius: 9,
          borderWidth: 2,
          borderColor: "#37B7C3",
        }}
      >
        <Pressable
          style={{
            flexDirection: "row",
            justifyContent: "center",
            gap: 5,
            margin: 10,
            width: "30%"
          }}
          onPress={() =>
            router.push({
              pathname: "/review",
              params: {
                bookObject: JSON.stringify(book),
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
        <View
          style={{
            justifyContent: "center",
            width: "70%"
          }}
        >
          <AddToShelf book={book} />
        </View>
      </View>
    </View>
  );
}
