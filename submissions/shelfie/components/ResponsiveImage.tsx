import { useState } from "react";
import { Image, Pressable } from "react-native";
import { ImagePropItem } from "./Types";

export default function ResponsiveImage(props: ImagePropItem) {
  let [resizeMode, setResizeMode] = useState(false);
  return ( 
    <Pressable onPress={()=>{setResizeMode(!resizeMode)}}>
      <Image
        source={{
          uri: props.url,
        }}
        style={{
          ...props.style,
          resizeMode: resizeMode ? "contain" : "cover",
        }}
      />
    </Pressable>
  );
}
