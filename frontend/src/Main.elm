module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
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
      , lastPagination = Initial
      }
    , loadGrid Nothing Initial serverUrl
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

        PreviousPage ->
            case model.gridData of
                Loaded (Just data) ->
                    ( { model | gridData = Loading, lastPagination = Left }
                    , loadGrid (Just data.pageInfo) Left model.serverUrl
                    )

                _ ->
                    ( model, Cmd.none )

        NextPage ->
            case model.gridData of
                Loaded (Just data) ->
                    ( { model | gridData = Loading, lastPagination = Right }
                    , loadGrid (Just data.pageInfo) Right model.serverUrl
                    )

                _ ->
                    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Example App"
    , body =
        [ Grid.container []
            [ Grid.row []
                [ Grid.col []
                    (case model.gridData of
                        Loading ->
                            [ Html.text "..." ]

                        Errored ->
                            [ Html.text "!" ]

                        Loaded (Just page) ->
                            [ viewGrid page ]

                        Loaded Nothing ->
                            [ Html.text "---" ]
                    )
                ]
            , Grid.row []
                [ Grid.col []
                    (viewNavigation model)
                ]
            ]
        ]
    }


viewGrid : GridDataResponse -> Html.Html msg
viewGrid data =
    Table.simpleTable
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


viewNavigation : Model -> List (Html.Html Msg)
viewNavigation model =
    case model.gridData of
        Loaded (Just data) ->
            [ Button.button
                [ Button.disabled (not (data.pageInfo.hasPreviousPage || model.lastPagination == Right))
                , Button.onClick PreviousPage
                ]
                [ Html.text "Poprzednia strona" ]
            , Button.button
                [ Button.disabled (not (data.pageInfo.hasNextPage || model.lastPagination == Left))
                , Button.onClick NextPage
                ]
                [ Html.text "Następna strona" ]
            ]

        _ ->
            [ Button.button
                [ Button.disabled True
                ]
                [ Html.text "Poprzednia strona"
                ]
            , Button.button [ Button.disabled True ] [ Html.text "Następna strona" ]
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
    { hasNextPage : Bool
    , hasPreviousPage : Bool
    , startCursor : Maybe String
    , endCursor : Maybe String
    }


pageInfo : SelectionSet PageInfo Schema.Object.PageInfo
pageInfo =
    Graphql.SelectionSet.succeed PageInfo
        |> with Schema.Object.PageInfo.hasNextPage
        |> with Schema.Object.PageInfo.hasPreviousPage
        |> with Schema.Object.PageInfo.startCursor
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
    , lastPagination : Direction
    }


loadGrid : Maybe PageInfo -> Direction -> String -> Cmd Msg
loadGrid info direction serverUrl =
    gridQuery info direction
        |> Graphql.Http.queryRequest serverUrl
        |> Graphql.Http.send GridLoaded


type Direction
    = Initial
    | Left
    | Right


gridQuery : Maybe PageInfo -> Direction -> SelectionSet (Maybe GridDataResponse) RootQuery
gridQuery info direction =
    Schema.Query.persons (getQueryParams info direction) gridDataResponse


getQueryParams : Maybe PageInfo -> Direction -> Schema.Query.PersonsOptionalArguments -> Schema.Query.PersonsOptionalArguments
getQueryParams maybeInfo direction arguments =
    case maybeInfo of
        Nothing ->
            { arguments
                | first = Graphql.OptionalArgument.Present 4
            }

        Just info ->
            case direction of
                Initial ->
                    { arguments
                        | first = Graphql.OptionalArgument.Present 4
                    }

                Left ->
                    { arguments
                        | last = Graphql.OptionalArgument.Present 4
                        , before =
                            case info.startCursor of
                                Just c ->
                                    Graphql.OptionalArgument.Present c

                                Nothing ->
                                    Graphql.OptionalArgument.Absent
                    }

                Right ->
                    { arguments
                        | first = Graphql.OptionalArgument.Present 4
                        , after =
                            case info.endCursor of
                                Just c ->
                                    Graphql.OptionalArgument.Present c

                                Nothing ->
                                    Graphql.OptionalArgument.Absent
                    }


type Msg
    = GridLoaded (Result (Graphql.Http.Error (Maybe GridDataResponse)) (Maybe GridDataResponse))
    | UrlRequested
    | UrlChanged
    | PreviousPage
    | NextPage
