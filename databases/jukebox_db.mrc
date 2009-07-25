on *:START:{
  set %jukebox_ctl_db $sqlite_open(jukebox_ctl.db)
  if (!%jukebox_ctl_db) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
  sqlite_exec %jukebox_ctl_db CREATE TABLE IF NOT EXISTS nicks (id INTEGER PRIMARY KEY  AUTOINCREMENT , nick TEXT UNIQUE NOT NULL , last TEXT NOT NULL , date TEXT NOT NULL  DEFAULT CURRENT_TIMESTAMP)
  sqlite_exec %jukebox_ctl_db CREATE TABLE IF NOT EXISTS curList (id INTEGER PRIMARY KEY  AUTOINCREMENT ,  queNum TEXT UNIQUE NOT NULL , title TEXT )
}

on *:JOIN:# {
  var %table2 = INSERT INTO nicks (nick,last) values(" $+ $nick $+ ","dash")
  var %request2 = $sqlite_query(%jukebox_ctl_db, %table2)
  if (!%request2) {
    echo 4 -a Error: %sqlite_errstr
    return
  }
}



alias putQue {
  var %x = 1
  var %lLength = $dll(ac,meval,var_ll)
  while (%x <= %lLength) {
    var %safe_title = $sqlite_escape_string($dll(ac,meval,title %x))
    sqlite_exec %jukebox_ctl_db REPLACE INTO curList (queNum, title) VALUES (' $+ %x $+ ', ' $+ %safe_title $+ ')
    echo 3 -a added track: %x set title to %safe_title
    inc %x
  }
}


alias dbNext5 {
  if (!%jukebox_ctl_db) { return }
  var %xcnt = 1
  while ( %xcnt <= 5 ) {
    ;//echo 3 -a SELECT title FROM curList WHERE queNum = ' $+ $queue(playqueue,[ $+ [ %xcnt ] ]) $+ '
    var %sql = SELECT title FROM curList WHERE queNum = ' $+ $queue(playqueue,[ $+ [ %xcnt ] ]) $+ '
    var %request = $sqlite_query(%jukebox_ctl_db, %sql)
    if (!%request) {
      echo 4 -a Error: %sqlite_errstr
      return
    }

    if ($sqlite_num_rows(%request)) {
      set %title [ $+ [ %xcnt ] ]  $sqlite_fetch_single(%request)  
      	  //echo %title [ $+ [ %xcnt ] ]
    }
    inc %xcnt
  }


  sqlite_free %request
  if ($queue(playqueue).len >= 5) {
    msg %jukebox.chan There are $queue(playqueue).len Titles in the queue - The next 5 titles:  1.< $+ %title1 $+ > 2.< $+ %title2 $+ > 3.< $+ %title3 $+ > 4.< $+ %title4 $+ > 5.< $+ %title5 $+ > 
  }

  elseif ($queue(playqueue).len >= 4) {
    msg %jukebox.chan  The next 4 titles:  1.< $+ %title1 $+ > 2.< $+ %title2 $+ > 3.< $+ %title3 $+ > 4.< $+ %title4 $+ >  
  }

  elseif ($queue(playqueue).len >= 3) {
    msg %jukebox.chan The next 3 titles:  1.< $+ %title1 $+ > 2.< $+ %title2 $+ > 3.< $+ %title3 $+ >  
  }

  elseif ($queue(playqueue).len >= 2) {
    msg %jukebox.chan The next 2 titles:  1.< $+ %title1 $+ > 2.< $+ %title2 $+ >  
  }

  elseif ($queue(playqueue).len >= 1) {
    msg %jukebox.chan The next 1 titles:  1.< $+ %title1 $+ >  
  }

  elseif ($queue(playqueue).len >= 0) {
    msg %jukebox.chan Random Play - Play Queue is empty, use !playq to add titles.  | halt
  }



}

alias playlistman {
  if (!%jukebox_ctl_db) { return }
  var %opts = $strip($1)
  var %unick = $strip($2)
  var %plist = $strip($3-)
  var %ltitle = $opt

  if (%opts == add) {
    var %sql = SELECT title FROM curList WHERE queNum = ' $+ $queue(playqueue,[ $+ [ %xcnt ] ]) $+ '
  }
  elseif (%opts == del) {
  }
  elseif (%opts == rename) {
  }
  elseif (%opts == queue) {
  }
  elseif (%opts == list) {
        var %sql = SELECT list FROM plists WHERE nick = ? AND ltitle = ?
        var %result = $sqlite_query(%jukebox_ctl_db, %sql, %unick, %ltitle)
		%cplist = $sqlite_fetch_single(%result)
		var %theRendList = $plistRend(%cplist)
		//echo 3 -a the list named ( $+ %ltitle $+ ) contains the following films: %theRendList
  }

  else {
  }
}

alias plistRend {
  if (!%jukebox_ctl_db) { return }
  var %theNumbers = $1-
  var %xcnt = 1
  while ( %xcnt <= 5 ) {
    ;//echo 3 -a SELECT title FROM curList WHERE queNum = ' $+ $queue(playqueue,[ $+ [ %xcnt ] ]) $+ '
    var %sql = SELECT title FROM curList WHERE queNum = ' $+ $queue(playqueue,[ $+ [ %xcnt ] ]) $+ '
    var %request = $sqlite_query(%jukebox_ctl_db, %sql)
    if (!%request) {
      echo 4 -a Error: %sqlite_errstr
      return
    }

    if ($sqlite_num_rows(%request)) {
      set %title [ $+ [ %xcnt ] ]  $sqlite_fetch_single(%request)  
      	  //echo %title [ $+ [ %xcnt ] ]
    }
    inc %xcnt
  }
var %finRes = 1.< $+ %title1 $+ > 2.< $+ %title2 $+ > 3.< $+ %title3 $+ > 4.< $+ %title4 $+ > 5.< $+ %title5 $+ > 
//echo 7 -a %finRes
return %finRes
}
