/*_____________________________________________________________________________
|/
/  libJbox by Jeff "dashdingo" Potter <diginom.bot@gmail.com>
|
|
|      Support library for JTV_Jukebox v.01
|
|      $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len))
|
|
|
|
|
|
|
|
|\     
| \    
* |    
|     
* |    
| *    
\ 
_\_____________________________________________________________________________
*/





on *:LOAD: {
  echo -a Loaded libJbox v.02a  
}

alias jboxon {
  //dll ac mexec setshuffle off
  //dll ac mexec setrepeat off
  runq
  .timerJboxon 0 5 runq
}

alias jboxoff {
  .timerJboxon* off
  //dll ac mexec control stop
}

alias skip {
  .jboxoff
  .timer 1 1 runq
  .timerJboxon 0 5 runq
}

alias volcheck {
  var %curVol = $dll(ac,meval,var_vol)
  //describe %jukebox.chan Volume is currently set to - %curVol
}

alias runq {
  getvars
  if (%secondsleft <= 2) {  
    if ($queue(playqueue).len > 0) && (%playingnow == 0) {
      .timerPlayq 1 1 //dll ac mexec play $queue(playqueue).next
    }
    elseif ($queue(playqueue).len == 0) && (%playingnow == 0) {
      .timerPlayq 1 1 randplay
    }
  }
  elseif (%songlength == $calc(%secondsleft - 1)) || (!%songlength) || (!%playingnow) {
    if ($queue(playqueue).len > 0) {
      //dll ac mexec play $queue(playqueue).next
    }
    elseif ($queue(playqueue).len == 0) {
      randplay
    }
  }
}

alias playq {
  set %playingnow $dll(ac,meval,var_stat)
  if !$strip($1) { msg %jukebox.chan No song specified | halt } 
  if ($queue(playqueue).len > 0) && (%playingnow == 1) {
    queue playqueue $strip($1)
    msg %jukebox.chan Queued Movie: $1 - < $+ $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len)) $+ > - Queue Position $queue(playqueue).len
  }
  elseif ($queue(playqueue).len > 0) && (%playingnow == 0) {
    queue playqueue $strip($1)
    msg %jukebox.chan Queued Movie: $1 - < $+ $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len)) $+ > - Queue Position $queue(playqueue).len
    //dll ac mexec play $queue(playqueue).next
  }
  elseif ($queue(playqueue).len == 0) && (%playingnow == 0) {
    queue playqueue $strip($1)
    //dll ac mexec play $queue(playqueue).next
  }
  if ($queue(playqueue).len == 0) && (%playingnow == 1) {
    queue playqueue $strip($1)
    msg %jukebox.chan Queued Movie: $1 - < $+ $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len)) $+ > - Queue Position $queue(playqueue).len
  }
}

/*
alias dumpq {
  while ($queue(playqueue).len) {
    echo -a $queue(playqueue).next
  }
  msg %jukebox.chan Queue emptied 
  next5
}
*/

alias dumpq {
  while ($queue(playqueue).len) {
    var %jukebox.oldq = %jukebox.oldq $+ - $+ $queue(playqueue).next
    ;   echo -a $queue(playqueue).next
  }
  msg %jukebox.chan Queue emptied - old Queue list was %jukebox.oldq
  next5
}

alias rand10 {
  var %randcount1 = $calc($queue(playqueue).len + 10)
  .getvars
  while ($queue(playqueue).len < %randcount1) {
    var %randsong = $rand(1,%listlength)
    queue playqueue %randsong
    inc %randcount
  }
  msg %jukebox.chan $nick added 10 random Movies to the queue.
  next5
}

alias rand5 {
  var %randcount2 = $calc($queue(playqueue).len + 5)
  .getvars
  while ($queue(playqueue).len < %randcount2) {
    var %randsong = $rand(1,%listlength)
    queue playqueue %randsong
    inc %randcount
  }
  msg %jukebox.chan $nick added 5 random Movies to the queue.
  next5
}

alias multiplay {
  set %playingnow $dll(ac,meval,var_stat)
  ;if !$strip($1) { msg %jukebox.chan No Movie specified | halt }
  var %songs = $1- 
  var %n = 1
  var %songadd
  while ( $gettok(%songs,%n,32) ) {
    ;msg %jukebox.chan Queued Song: $1 - < $+ $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len)) $+ > - Queue Position $queue(playqueue).len
    ;//echo -a command would have been -> queue playqueue $strip($v1)
    //queue playqueue $strip($v1)
    %songadd = %songadd $+ $chr(32) $+ %n $+ . $+ < $+ $dll(ac,meval,title $queue(playqueue,$queue(playqueue).len)) $+ >
    inc %n
  }
  msg %jukebox.chan Movies added to queue: %songadd
}

alias songtime {
  set %songlength $dll(ac,meval,var_sl)

}

alias secondsleft {
  set %secondsleft $dll(ac,meval,var_sle)
}

alias stoplay {
  .secondsleft
  if (%secondsleft <= 1)
  //dll ac mexec control stop
}

alias randplay {
  set %randsong $rand(1,%listlength)
  //dll ac mexec play %randsong
}

alias nowplay {
  //dll ac mexec announce
}

alias next5 {
  if ($queue(playqueue).len == 0) { msg %jukebox.chan Random Play - Play Queue is empty, use !playq to add Movies.  | halt }
  if ($queue(playqueue).len == 1) { msg %jukebox.chan The next Movie:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > }  
  if ($queue(playqueue).len == 2) { msg %jukebox.chan The next 2 Movies:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > 2.< $+ $dll(ac,meval,title $queue(playqueue,2)) $+ > }  
  if ($queue(playqueue).len == 3) { msg %jukebox.chan The next 3 Movies:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > 2.< $+ $dll(ac,meval,title $queue(playqueue,2)) $+ > 3.< $+ $dll(ac,meval,title $queue(playqueue,3)) $+ > }  
  if ($queue(playqueue).len == 4) { msg %jukebox.chan The next 4 Movies:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > 2.< $+ $dll(ac,meval,title $queue(playqueue,2)) $+ > 3.< $+ $dll(ac,meval,title $queue(playqueue,3)) $+ > 4.< $+ $dll(ac,meval,title $queue(playqueue,4)) $+ > }  
  if ($queue(playqueue).len == 5) { msg %jukebox.chan The next 5 Movies:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > 2.< $+ $dll(ac,meval,title $queue(playqueue,2)) $+ > 3.< $+ $dll(ac,meval,title $queue(playqueue,3)) $+ > 4.< $+ $dll(ac,meval,title $queue(playqueue,4)) $+ > 5.< $+ $dll(ac,meval,title $queue(playqueue,5)) $+ > }  
  if ($queue(playqueue).len > 5) { msg %jukebox.chan  The next 5 out of $queue(playqueue).len Movies:  1.< $+ $dll(ac,meval,title $queue(playqueue,1)) $+ > 2.< $+ $dll(ac,meval,title $queue(playqueue,2)) $+ > 3.< $+ $dll(ac,meval,title $queue(playqueue,3)) $+ > 4.< $+ $dll(ac,meval,title $queue(playqueue,4)) $+ > 5.< $+ $dll(ac,meval,title $queue(playqueue,5)) $+ > }  
}

alias checkvars {
  unset %songlength,%secondsleft,%playingnow.%listlength
  set %listlength $dll(ac,meval,var_ll)
  set %songlength $dll(ac,meval,var_sl)
  set %secondsleft $dll(ac,meval,var_sle)
  set %playingnow $dll(ac,meval,var_stat)
  msg %jukebox.chan  Playlist Length: %listlength - Movie Length: %songlength - Seconds Left: %secondsleft - State: %playingnow
}

alias getvars {
  unset %songlength,%secondsleft,%playingnow,%listlength
  set %listlength $dll(ac,meval,var_ll)
  set %songlength $dll(ac,meval,var_sl)
  set %secondsleft $dll(ac,meval,var_sle)
  set %playingnow $dll(ac,meval,var_stat)
}
alias movietimeleft { 
  //describe %jukebox.chan Time Left: $left($calc($dll(ac,meval,var_sle) / 60),4) 
}
alias jboxnextplay { 
  //describe %jukebox.chan NextPlaying: $dll(ac,meval,title $queue(playqueue,1)) Starting in:  $left($calc($dll(ac,meval,var_sle) / 60),4) $+ mins.
}

alias rque {

  if (!$strip($2)) { 
    msg $chan you have to tell me which queue postion to replace and a movie # to replace it. 
    halt
  }
  else {
    var %playq.cnt = 1
    ;var %theTitles = 0
    %pqle = $queue(playqueue).len
    while (%pqle >= %playq.cnt) {
      ;//echo 4 -a The queue is now : %playq.cnt
      %theTitles = %theTitles $+ $chr(32) $+ $queue(playqueue,%playq.cnt)
      inc %playq.cnt
    }
    //echo 6 -a The list was : %theTitles
    %theTitles = $puttok(%theTitles,$2,$1,32)
    /echo 6 -a The list is now : %theTitles
    //queue -d playqueue 
    var %m = 1
    while ( $gettok(%theTitles,%m,32) ) {
      //queue playqueue $strip($v1)
      inc %m
    }
    ;next5


  }
  unset %theTitles
}
