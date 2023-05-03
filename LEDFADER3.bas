'My brother Eric stuck some high powered RGB LEDs in his snare drum for eyecandy
'to use during Dutch carnaval. but the included controller just flashed
'some colors randomly which wasn't very attractive. So I asked him,
'wouldn't be nice to have a color change on every drum hit.
'ofcourse a stupid thing to say...I had a new project ;-)
'
'Zet interne RC oscillator op 8MHz en geen prescaler
'
$regfile = "attiny2313.dat"
$crystal = 1000000
'$prog &HFF , &HC4 , &HDF , &HFF                             ' generated. Take care that the chip supports all fuse bytes.
'$prog &HFF , &H84 , &HDF , &HFF                             ' generated. Take care that the chip supports all fuse bytes.
'$prog &HFF , &H84 , &HDF , &HFF                             ' generated. Take care that the chip supports all fuse bytes.

$hwstack = 32
$swstack = 10
$framesize = 32


Config Pind.3 = Input
Config Pinb.2 = Output                                      ' PWM-Pins are output
Config Pinb.3 = Output
Config Pinb.4 = Output

Config Timer0 = Pwm , Pwm = On , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down       'Put Timers in PWM-Mode
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down

Config Int1 = Falling                                       '

Enable Timer0
Enable Timer1                                               ' you have to use enable for OC2,else nothings will happen!
Start Timer0
Start Timer1


Dim Stap As Byte
Dim Count As Byte
Dim Strobe As Byte


Rood Alias Ocr1bl                                           'PWM-Pin 14 - Red
Groen Alias Ocr1al                                          'PWM-Pin 15 - Green
Blauw Alias Ocr0a                                           'PWM-Pin 16 - Blue

Enable Interrupts
Enable Int1                                                 'pin7  (pind.3)

On Int1 Stapjes

Startplaats:
Waitms 40                                                   ' it's not legal to do a drum roll over 25 Hz (I was told)
'deze tijd stond in de stapjes routine

'-------------------------------{ Fade to black }-------------------------------
   Do                                                       'start fading out the last chosen colour
      If Rood <> 0 Then Decr Rood                           'yes I know it doesn't add up exactly...
      If Groen <> 0 Then Decr Groen                         'too bad for value 77
      If Blauw <> 0 Then Decr Blauw
      Waitms 5
   Loop Until Rood = 0 And Groen = 0 And Blauw = 0
  Waitms 2500                                               'wait for the applause from previous act to recide

Do                                                          'alles buiten de interrupt routine

'------------------------------{ red heartbeat }--------------------------------
Heartbeat:
Count = 31

Do
   Decr Count
      Do
         Incr Rood                                          'fade in  to max
         Waitms 1
      Loop Until Rood = 255

      Do
         Decr Rood                                          'fade out a little
         Waitms 1
      Loop Until Rood = 30

      Waitms 100

      Do
         Incr Rood                                          'fade In  to max
         Waitms 1
      Loop Until Rood = 255

      Do
         Decr Rood                                          'fade out to zero
         Waitms 1
      Loop Until Rood = 0

      Waitms 1000                                           'wait a sec
Loop Until Count = 0

      Rood = 0
      Groen = 0
      Blauw = 0
      Waitms 2500

'------------------------------{ Rainbow fade }--------------------------------
Rainbow:
   Count = 1
Do
    Decr Count                                              'do a rainbow fade
      Rood = 255
       Do
          Incr Groen
          Waitms 30
       Loop Until Groen = 255
       Do
          Decr Rood
          Waitms 30
       Loop Until Rood = 0

       Do
          Incr Blauw
          Waitms 30
       Loop Until Blauw = 255

       Do
          Decr Groen
          Waitms 30
       Loop Until Groen = 0

          Waitms 500

       Do
          Incr Rood
          Waitms 50
       Loop Until Rood = 255

       Do
          Decr Blauw
          Waitms 50
       Loop Until Blauw = 0

          Waitms 1000
       Rood = 0
Loop Until Count = 0

    Rood = 0
    Groen = 0
    Blauw = 0
    Waitms 2500

 '------------------------------{ Strobe light }--------------------------------
 Stroboscope:
   Strobe = 255

    Do
       Decr Strobe
       Rood = 255
       Groen = 255
       Blauw = 255
       Waitms 40
       Rood = 0
       Groen = 0
       Blauw = 0
       Waitms 40
    Loop Until Strobe = 0
Loop
End

'-------------------------------------{ Steps }---------------------------------
Stapjes:                                                    'if PIND.3 is low (Eric hits his drum) index color

   For Count = 0 To 10
      Rood = 255
      Waitms 250
      Rood = 0
      Waitms 250
   Next Count

   Incr Stap                                                '
   If Stap = 13 Then Stap = 1                               'rolling around in the DATA line below
   Rood = Lookup(stap , Red)
   Groen = Lookup(stap , Green)
   Blauw = Lookup(stap , Blue)
                                                    ' Goto Startplaats
Return

'colorwheel  in opposite color sequence
'.......1.....7.....2.....8.....3.....9.....4....10.....5....11....6.....12   'there are still 12 colors
Red:
 Data 255 , 000 , 255 , 000 , 255 , 000 , 077 , 077 , 000 , 255 , 000 , 255
Green:
 Data 000 , 255 , 077 , 077 , 255 , 000 , 255 , 000 , 255 , 000 , 255 , 000
Blue:
 Data 000 , 255 , 000 , 255 , 000 , 255 , 000 , 255 , 000 , 255 , 077 , 077