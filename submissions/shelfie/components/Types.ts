export type Book = {
  title: string;
  authors: string;
  description: string;
  etag: string;
  category: string[];
};

export type Review = {
  content: any,
  meta: {
    title: string;
    authors: string;
    etag: string;
  };
  emotions: string;
  username: string;
  uuid: string;
  liked: string[];
};

export type User = {
  username: string;
  uuid: string;
}
export type ImagePropItem = {
  url: string;
  style: object;
};

export type ReviewPropItem = {
  review: Review;
  key: number;
  uuid: string;
  showBorder: boolean;
};

export const APIEndpoint: string = 'https://shelfie.pidgon.com'