#!/usr/bin/env bash

TOKEN="YOUR_BOT_TOKEN" # Bot Token
# TOKEN="YOUR_USER_TOKEN" # User Token
CHANNEL="YOUR_CHANNEL_ID" # times_tanaka_naoto

#
# チャンネルのメッセージを取得
# スレッド内のメッセージは取得できない
# https://api.slack.com/methods/conversations.history
#
getMessages() {
  curl -X GET \
  https://slack.com/api/conversations.history?channel=${CHANNEL} -H "Authorization: Bearer ${TOKEN}" | jq
}

#
# スレッド内のメッセージを取得
# https://api.slack.com/methods/conversations.replies
#
getThreadMessages() {
  local ts="$1"
  curl -X GET \
  "https://slack.com/api/conversations.replies?ts=${ts}&channel=${CHANNEL}" -H "Authorization: Bearer ${TOKEN}" | jq
}

#
# メッセージ送信
# https://api.slack.com/methods/chat.postMessage
#
postMessage() {
  local blocks="$1"
  local threadTs="$2" # スレッドに繋げたい場合のts
  curl -X POST -F channel=${CHANNEL} -F blocks="${blocks}" -F thread_ts="$threadTs"\
  https://slack.com/api/chat.postMessage -H "Authorization: Bearer ${TOKEN}" | jq
}

#
# メッセージ削除
# tsnの取得はメッセージ > リンクのコピー > 末尾6桁をコンマで区切る
# 例：https://yourcompany.slack.com/archives/C02QYEXA8SW/p1655772179432789の場合、1655772179.432789
#
deleteMessage() {
  local ts="$1"
  [ -z "$ts" ] && return
  curl -X POST -F channel=${CHANNEL} -F ts=${ts} \
  https://slack.com/api/chat.delete -H "Authorization: Bearer ${TOKEN}" | jq
}

#
# スレッドのメッセージ全て削除
# https://api.slack.com/methods/chat.delete
#
deleteThreadMessages() {
  local ts="$1"
  getThreadMessages $ts | jq -r ".messages[].ts" | while read line;do
    deleteMessage $line
  done
}

#
# ファイル送信
# https://api.slack.com/methods/files.upload
#
postFile() {
  local file=$1
  local threadTs="$2"
  curl -X POST -F channels=${CHANNEL} -F file=@${file} -F thread_ts="${threadTs}" \
  https://slack.com/api/files.upload -H "Authorization: Bearer ${TOKEN}" | jq
}
