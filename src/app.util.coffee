app.util = {}

app.util.date_to_string = (date) ->
  fn = (a) -> (if a < 10 then "0" else "") + a

  date.getFullYear() +
  "/" + fn(date.getMonth() + 1) +
  "/" + fn(date.getDate()) +
  " " + fn(date.getHours()) +
  ":" + fn(date.getMinutes())

# #app.util.calc_heat
# スレの勢いを算出する関数  
# 引数は現在の時刻、スレが立てられた時刻、スレのレス数  
# 文字列を返す
app.util.calc_heat = (now, thread_created, res_count) ->
  (res_count / ((now - thread_created) / (24 * 60 * 60 * 1000))).toFixed(1)

# #app.util.anchor_parse
# 文字列中の全てのアンカーの情報をパースする
app.util.parse_anchor = (str) ->
  total =
    data: []
    target: 0

  anchor_reg = /(?:>|&gt;|＞){1,2}[\d\uff10-\uff19]+(?:[\-ー][\d\uff10-\uff19]+)?(?:\s*,\s*[\d\uff10-\uff19]+(?:[\-ー][\d\uff10-\uff19]+)?)*/g
  while anchor_res = anchor_reg.exec(str)
    anchor_str = anchor_res[0]
      .replace(/ー/g, "-")
      .replace /[\uff10-\uff19]/g, ($0) ->
        String.fromCharCode($0.charCodeAt(0) - 65248)

    anchor =
      segments: []
      target: 0

    segment_reg = /(\d+)(?:-(\d+))?/g
    while segment_res = segment_reg.exec(anchor_str)
      if segment_res[2]
        segrange_start = +segment_res[1]
        segrange_end = +segment_res[2]
      else
        segrange_start = segrange_end = +segment_res[1]

      anchor.target += segrange_end - segrange_start + 1
      anchor.segments.push([segrange_start, segrange_end])

    total.target += anchor.target
    total.data.push(anchor)

  total

#2chの鯖移転検出関数
#移転を検出した場合は移転先のURLをresolveに載せる
#検出出来なかった場合はrejectする
#htmlを渡す事で通信をスキップする事が出来る
app.util.ch_server_move_detect = (old_board_url, html) ->
  $.Deferred (deferred) ->
    if typeof html is "string"
      deferred.resolve(html)
    else
      deferred.reject()

  #htmlが渡されなかった場合は通信する
  .pipe null, ->
    $.Deferred (deferred) ->
      xhr = new XMLHttpRequest()
      timer = setTimeout (-> xhr.abort()), 1000 * 30
      xhr.onreadystatechange = ->
        if this.readyState is 4
          clearTimeout(timer)

          if xhr.status is 200
            deferred.resolve(xhr.responseText)
          else
            deferred.reject()

      xhr.overrideMimeType("text/html; charset=Shift_JIS")
      xhr.open("GET", "#{old_board_url}?_#{Date.now()}")
      xhr.send(null)

  #htmlから移転を判定
  .pipe (html) ->
    $.Deferred (deferred) ->
      res = ///location\.href="(http://\w+\.2ch\.net/\w*/)"///.exec(html)

      if res and res[1] isnt old_board_url
        deferred.resolve(res[1])
      else
        deferred.reject()

  #移転を検出した場合は移転検出メッセージを送出
  .done (new_board_url) ->
    app.message.send("detected_ch_server_move",
      {before: old_board_url, after: new_board_url})

  .promise()
