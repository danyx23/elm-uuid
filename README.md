#Elm MimeType

Models the most common mime types as a Union type in Elm and provides a method to 
parse mime types from a string.

The basic usage is to parse the mime type from a string identifier and then match against it, e.g.

```elm
let
    maybeMimeType = parseMimeType someMimeIdentifierString
  in
    case maybeMimeType of
      Nothing ->
        "Could not be parsed as a mime type at all"
      Just mimeType ->
        case mimeType of
          Image subtype ->
            if (subtype == MimeType.Jpeg) then
              "Successfully parsed as jpeg image"
            else
              "Some image, but not a jpeg"
          _ ->
            "Other mime type"      
```

by Daniel Bachler