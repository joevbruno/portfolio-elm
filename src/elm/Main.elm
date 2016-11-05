import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Process exposing (..)
import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, oneOf, null, list, bool, (:=))
import Task
import Debug exposing (..)

main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }

type alias Section =
  { className: String
  , icon: String
  , title: String
  , subtitle: String
  , description: List String
  , metaTitle: String
  }

type alias Contact =
  { title: String
  , label: String
  }

type alias Contacts =
  { name: String
  , link: String
  , icon: String
  }

type alias Profile =
  { sections: List Section
  , contact: Contact
  , contacts: List Contacts
  }

-- MODEL
type alias Model =
  { isLoading: Bool
  , error: Bool
  , active: Bool
  , profile: Maybe (Profile)
  }

initialModel: Model
initialModel =
  { isLoading = True
  , error = False
  , active = False
  , profile = Nothing
  }

init : (Model, Cmd Msg)
init =
  (initialModel, getProfile)

-- methods

sectionDecoder: Json.Decoder Section
sectionDecoder =
  Json.object6
    Section
    ("className" := Json.string)
    ("icon" := Json.string)
    ("title" := Json.string)
    ("subtitle" := Json.string)
    ("description" := Json.list Json.string)
    ("metaTitle" := Json.string)

contactsDecoder: Json.Decoder Contacts
contactsDecoder =
    Json.object3
      Contacts
      ("name" := Json.string)
      ("link" := Json.string)
      ("icon" := Json.string)

contactDecoder : Json.Decoder Contact
contactDecoder =
  Json.object2
    Contact
    ("title" := Json.string)
    ("label" := Json.string)

profileDecoder : Json.Decoder (Maybe Profile)
profileDecoder =
  Json.maybe <|
    Json.object3
      Profile
      ("sections" := Json.list sectionDecoder)
      ("contact" := contactDecoder)
      ("contacts" := Json.list contactsDecoder)



getProfile : Cmd Msg
getProfile =
  let
    url =
      "/data.json"
  in
    Task.perform FetchFail FetchSucceed (Http.get profileDecoder url)

-- UPDATE

type Msg
  = Update
  | NoOp
  | FetchSucceed (Maybe Profile)
  | FetchFail Http.Error
  | ShowMenu Bool
  | CloseMenuIfNecessary
  | SleepSucceed
  | SleepFail

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    Update -> (model, Cmd.none)
    FetchSucceed profile ->
      ({ model | profile = profile },
      Process.sleep (2000)
        |> Task.perform (\_ ->  NoOp) (\_ -> SleepSucceed))
    FetchFail e ->
      log (toString e) (model, Cmd.none)
    SleepSucceed ->
      ({ model | isLoading = False }, Cmd.none)
    SleepFail ->
      ({ model | error = True }, Cmd.none)
    CloseMenuIfNecessary ->
      if (model.active == True) then ({ model | active = False }, Cmd.none)
      else (model, Cmd.none)
    ShowMenu active ->
      if (active == True) then ({ model | active = False }, Cmd.none)
      else ({ model | active = True }, Cmd.none)

getMouseIcon: String -> Html Msg
getMouseIcon section =
  if (section == "greeting") then
    div [ class "mouse_scroll" ] [
      div [class "mouse"] [
        div [ class "wheel"] []
     ]
     , div [] [
        span [ class "m_scroll_arrows unu" ] []
      ]
    ]
  else
    div [] []

getContacts: Contact -> Html Msg
getContacts { title, label } =
  div [ class "contact" ] [
    h5 [ class "contact__title"] [ text title ]
    , button [ class "contact__button", id "contact-btn" ] [ text label ]
  ]

getDescription: String -> Html Msg
getDescription description =
  p [ class "description" ] [text description]

getTitleGroup: String -> String -> Html Msg
getTitleGroup title subtitle =
  if String.length title ==  0 && String.length subtitle == 0 then
    div [ class "blank" ] []
  else
    div [ class "titleGroup" ] [
      h2 [ class "title" ] [text title]
      , h5 [ class "subtitle" ] [text subtitle]
    ]

getMetaTitle: String -> Html Msg
getMetaTitle metaTitle =
  if (length metaTitle) == 0 then
    span [] []
  else
    span [ class "metaTitle"] [ text metaTitle ]

getSection: Section -> Html Msg
getSection section =
  let
    mouseIcon = getMouseIcon section.className
    metaTitle = getMetaTitle section.metaTitle
  in
  div [ class section.className, id section.className, onClick CloseMenuIfNecessary ] [
    div [ class "content" ] [
    div [ class "icon" ] []
    , getTitleGroup section.title section.subtitle
    , div [ class "descriptionGroup" ] (List.map getDescription section.description)
    , mouseIcon
    , getMetaTitle section.metaTitle
    ]
  ]

getFooter: Html Msg
getFooter =
  footer [ class "footer" ] [
    span [ class "lang" ] [ text "Built with Elm"]
    , span [ class "legal" ] [ text "© Joe Bruno. All rights reserved. Forever. 😃"]
  ]

getMenuClass: Bool -> String
getMenuClass active =
  if (active) then "menu isActive"
  else "menu"

displayMenuItem: Contacts -> Html Msg
displayMenuItem contact =
  a [ class ("menu-item " ++ contact.icon), href contact.link, target "__blank" ] [ text contact.name ]

getMenuList: List Contacts -> Html Msg
getMenuList menuItems =
  div [ class "menu-container" ]
    (List.map displayMenuItem menuItems)

menuComp: Bool -> List Contacts -> Html Msg
menuComp active menuList =
  let
    className = getMenuClass active
  in
    div [ class className ] [
      div [ class "hamburger-container" , onClick (ShowMenu active) ] [
        span [
          class "hamburger"
          ] []
        ]
      , (getMenuList menuList)
    ]


displayNavigation: Bool -> Maybe Profile -> Html Msg
displayNavigation active profile =
  case profile of
    Just profile ->
      let
        contacts = profile.contacts
      in
        nav [ class "nav", id "nav" ] [
          div [ class "logo" ] []
          , div [ class "menu" ] [
            (menuComp active contacts)
          ]
        ]
    Nothing -> p [ style [("font-size", "32"), ("margin-top", "100px")] ] []

getApp: Maybe Profile -> Html Msg
getApp profile =
  case profile of
    Just profile ->
      div [ class "app" ] [
        div [ class "sections"] (List.map getSection profile.sections)
        , (getContacts profile.contact)
        , (getFooter)
      ]
    Nothing -> p [ style [("font-size", "32"), ("margin-top", "100px")] ] []

getLoaderClasses: Bool -> String
getLoaderClasses isLoading =
  if isLoading then "loading-container active"
  else "loading-container"

getLoader: Bool -> Html Msg
getLoader isLoading =
    div [ class (getLoaderClasses isLoading)] [
      div [ class "jumper"] [
        div [] []
        , div [] []
        , div [] []
      ]
    ]
-- VIEW

view : Model -> Html Msg
view { isLoading, active, profile } =
  div []
    [ (displayNavigation active profile)
    , getApp profile
    , getLoader isLoading
    ]



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
