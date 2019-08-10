module Main exposing (main)

import Bootstrap.Grid as Grid
import Bootstrap.Table as Table
import Browser
import Browser.Navigation as Nav
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument
import Graphql.SelectionSet exposing (SelectionSet, nonNullElementsOrFail, with)
import Html
import List
import Schema.Object
import Schema.Object.PageInfo
import Schema.Object.Person
import Schema.Object.PersonsConnection
import Schema.Object.PersonsEdge
import Schema.Query
import Url


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = \_ -> UrlRequested
        , onUrlChange = \_ -> UrlChanged
        }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init serverUrl url key =
    ( { key = key
      , url = url
      , gridData = Loading
      , serverUrl = serverUrl
      }
    , loadGrid serverUrl
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested ->
            ( model, Cmd.none )

        UrlChanged ->
            ( model, Cmd.none )

        GridLoaded (Ok data) ->
            ( { model | gridData = Loaded data }
            , Cmd.none
            )

        GridLoaded (Err data) ->
            ( { model | gridData = Errored }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title = "Example App"
    , body =
        case model.gridData of
            Loading ->
                [ Html.text "..." ]

            Errored ->
                [ Html.text "!" ]

            Loaded (Just page) ->
                [ viewPage page ]

            Loaded Nothing ->
                [ Html.text "---" ]
    }


viewPage : GridDataResponse -> Html.Html msg
viewPage data =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ Table.simpleTable
                    ( Table.simpleThead
                        [ Table.th [] [ Html.text "First name" ]
                        , Table.th [] [ Html.text "Second name" ]
                        ]
                    , Table.tbody []
                        (List.map
                            (\row ->
                                Table.tr []
                                    [ Table.td [] [ Html.text row.firstName ]
                                    , Table.td [] [ Html.text row.lastName ]
                                    ]
                            )
                            data.persons
                        )
                    )
                ]
            ]
        ]


type GridData
    = Loading
    | Errored
    | Loaded (Maybe GridDataResponse)


type alias GridDataResponse =
    { pageInfo : PageInfo
    , persons : List PersonSummary
    }


gridDataResponse : SelectionSet GridDataResponse Schema.Object.PersonsConnection
gridDataResponse =
    Graphql.SelectionSet.succeed GridDataResponse
        |> with
            (Schema.Object.PersonsConnection.pageInfo pageInfo)
        |> with
            (Schema.Object.PersonsConnection.edges
                (Schema.Object.PersonsEdge.node personSummary)
                |> nonNullElementsOrFail
                |> nonNullElementsOrFail
            )


type alias PageInfo =
    { endCursor : Maybe String
    }


pageInfo : SelectionSet PageInfo Schema.Object.PageInfo
pageInfo =
    Graphql.SelectionSet.succeed PageInfo
        |> with Schema.Object.PageInfo.endCursor


type alias PersonSummary =
    { firstName : String
    , lastName : String
    }


personSummary : SelectionSet PersonSummary Schema.Object.Person
personSummary =
    Graphql.SelectionSet.succeed PersonSummary
        |> with Schema.Object.Person.firstName
        |> with Schema.Object.Person.lastName


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , gridData : GridData
    , serverUrl : String
    }


loadGrid : String -> Cmd Msg
loadGrid serverUrl =
    gridQuery
        |> Graphql.Http.queryRequest serverUrl
        |> Graphql.Http.send GridLoaded


gridQuery : SelectionSet (Maybe GridDataResponse) RootQuery
gridQuery =
    Schema.Query.persons identity gridDataResponse


type Msg
    = GridLoaded (Result (Graphql.Http.Error (Maybe GridDataResponse)) (Maybe GridDataResponse))
    | UrlRequested
    | UrlChanged
