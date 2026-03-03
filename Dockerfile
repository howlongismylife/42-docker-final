FROM golang:1.25-alpine AS build
WORKDIR /app

RUN apk add --no-cache sqlite

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -o tracker

RUN sqlite3 tracker.db "CREATE TABLE IF NOT EXISTS parcel (number INTEGER PRIMARY KEY AUTOINCREMENT, client INTEGER, status TEXT, address TEXT, created_at TEXT);"

FROM scratch
COPY --from=build /app/tracker /tracker
COPY --from=build /app/tracker.db /tracker.db
ENTRYPOINT ["/tracker"]