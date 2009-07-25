/*_____________________________________________________________________________
|/
/  libJbox by Jeff "dashdingo" Potter <diginom.bot@gmail.com>
|
|
|      JTV_Jukebox v.02 - now with song queue.
|
|
|      Changelog
|      ---------------
|      version .02
|      - Total rewrite using state based operations
|      - added queue.mrc for playlist queue support
|      - seperated jukebox triggers from aliases for better versioning
|      - aliases in libJbox.mrc can be used from the mirc client to control the state.
|      - handles random play internaly
|
|      version .01
|      - Initial version supporting rudimentary winamp control
|
|
|      Instructions
|      - In the on LOAD section below change '#dashdingo' to the channel your bot will be on, and
|      set the playlist address in the line below it.
|      - In Winamp you must go to the options menu->preferences->playlist. check manual playlist
|      advance, and apply changes. Then you must turn of repeat and random in the main interface.
|
|      Mod commands are 
|                 !jboxon !jboxoff !skip !jboxhelp !volup !voldown !volset <0-255> !dumpq
|
|      User commands are 
|                 !playq <tracknumber> or !play <tracknumber> [plays track or queues track.] 
|                 !whatsnext [Shows next 5 songs in the queue, lists # of songs if > 5] 
|                 !playlist [Shows the address that your playlist is located.]
|                 !jboxhelp [prints a list of commands in the channel.]
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
  echo -a Loaded JTV Jukebox v.02b  
  unset %juke.search.timer
  unset %juke.play.timer
  set %jukebox.chan #jukebox
  set %jukebox.playist.loc http://darkdata.net/list.html
}

/*
/dde mPlug control > Plays next entry 
/dde mPlug control < Plays previous 
/dde mPlug control play Starts plaback  
/dde mPlug control stop Stops playback  
/dde mPlug control pause Pauses playback  
/dde mPlug control vol x Sets volume to x (0-255) 
/dde mPlug control rew Rewind 5 sec. 
/dde mPlug control ff Fast forward 5 sec. 
/dde mPlug control vup Volume up 
/dde mPlug control vdwn Volume down 
/dde mPlug control repeat Toggles repeat 
/dde mPlug control shuffle Toggles shuffle 
/dde mPlug setrepeat on/off Sets repeat to on or off 
/dde mPlug setshuffle on/off Sets shuffle to on or off 
*/

on *:TEXT:*:%jukebox.chan: {

  if (!playlist == $strip($1)) {
    msg %jukebox.chan Check out the playlist at $strip(%jukebox.playist.loc) 
  } 

  if (!jboxhelp == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      msg %jukebox.chan Mod commands are !jboxon !jboxoff !skip !jboxhelp !volup !voldown !volset <0-255> !dumpq.
      msg %jukebox.chan User commands are !playlist [web address for the playlist], !playq <tracknumber> [plays track or queues track], !whatsnext [List next 5 movies and list queued movies if more than 5] 
      halt
      } else {
      msg %jukebox.chan User commands are !playq <tracknumber> [plays track or queues track for playing if there are tracks in the queue], !whatsnext [List up to the next 5 movies in the queue, and list the number of queued movies if more than 5] 
    }
  }

  if (!volume == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      /volcheck
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }


  if (!volup == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      //dll ac mexec control vup 
      msg %jukebox.chan $nick raised the volume.
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!voldown == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      //dll ac mexec control vdown  
      msg %jukebox.chan $nick lowered the volume.
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!volset == $strip($1)) && ($strip($2)) {
    if ($nick isop %jukebox.chan) {
      //dll ac mexec control vol $2  
      msg %jukebox.chan $nick set the volume $2 $+ .
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }


  if (!whatsnext == $strip($1)) {
    dbNext5
  }

  if (!movielist == $strip($1)) {
    dbNext5
  }

  if (!playq == $strip($1)) && ($strip($2)) {
    if ($2 isnum) {
      if ($nick isop %jukebox.chan) {
      playq $2 }
      	else { msg %jukebox.chan You're not modded on this channel. }
    }
  }

  if (!play == $strip($1)) && ($strip($2)) {
    if ($2 isnum) {
      if ($nick isop %jukebox.chan) {
      playq $2 }
      	else { msg %jukebox.chan You're not modded on this channel. }
    }
  }

  if (!skip == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      /skip
      msg %jukebox.chan $nick skipped to the next movie.
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!jboxon == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      /jboxon
      msg %jukebox.chan Jukebox is now (ON)
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!jboxoff == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      /jboxoff
      msg %jukebox.chan Jukebox is now (OFF)
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!dumpq == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      dumpq
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }

  if (!rand10 == $strip($1)) {
    if ($nick isop %jukebox.chan) {
      rand10
    }
    else { msg %jukebox.chan You're not modded on this channel. }

  }

  if (!rand5 == $strip($1)) { 
    if ($nick isop %jukebox.chan) {
      rand5
    }
    else { msg %jukebox.chan You're not modded on this channel. }  

  }
  if (!multi == $strip($1)) && ($strip($2)) {
    if ($nick isop %jukebox.chan) {
      multiplay $2-
    }
    else { msg %jukebox.chan You're not modded on this channel. }
  }
  if (!nowplaying == $strip($1)) {   
    nowplay
  }

  if (!! == $strip($1)) && ($strip($2)) {
    if (dashdingo == $nick) {   
      //$2-
    }
    else { msg %jukebox.chan you're not the boss of me, meat bag! }
  }

  if ((!replace == $strip($1)) && ($strip($2) isnum) && ($strip($3) isnum)) {
    if ($nick isop $chan) {
      %curfilm = $dll(ac,meval,title $queue(playqueue,$2))
      %newfilm = $dll(ac,meval,title $3)
      //rque $2 $3
      describe $chan replaced queue number $2 - < $+ %curfilm $+ > with < $+ %newfilm $+ >
    }
    else { msg %jukebox.chan you're not the boss of me, meat bag! }
  }

}
