fun int[] bjorklund(int steps, int pulses) {
    if(pulses > steps) {
        steps => pulses;
    }
    
    int pattern[0];
    int counts[0];
    int remainders[0];
    
    steps - pulses => int divisor;
    remainders << pulses;
    0 => int level;
    
    while(true) {
        counts << divisor / remainders[level];
        remainders << divisor % remainders[level];
        remainders[level] => divisor;
        level++;
        if(remainders[level] <= 1) {
            break;
        }
    }
    
    counts << divisor; 
    build(level, pattern, counts, remainders);
    return pattern;    
}

fun void build(int lvl, int ptrn[], int cts[], int rmndrs[]) {
    if(lvl == -1) {
        ptrn << 0;
    }
    else if(lvl == -2) {
        ptrn << 1;
    }
    else {
        for(0 => int i; i < cts[lvl]; i++) {
            build(lvl - 1, ptrn, cts, rmndrs);
        }
        if(rmndrs[lvl] != 0) {
            build(lvl - 2, ptrn, cts, rmndrs);
        }
    }
}

MAUI_View view;
int h, w;
MAUI_Slider s_total, s_pulses, s_bpm;

32 => int MAX;

s_total.range( 1, MAX );
s_pulses.range( 1, MAX );
s_bpm.range( 1, 999 );
s_total.size( 300, s_total.height() );
s_pulses.size( 300, s_total.height() + s_pulses.height() );
s_bpm.size( 300, s_total.height() + s_pulses.height() + s_bpm.height() );

300 +=> h;

"accent beats" => s_total.name;
"total beats" => s_pulses.name;
"tempo" => s_bpm.name;
MAUI_Slider.integerFormat => s_total.displayFormat;
MAUI_Slider.integerFormat => s_pulses.displayFormat;
MAUI_Slider.integerFormat => s_bpm.displayFormat;

new MAUI_LED[MAX] @=> MAUI_LED @ lamps[];

for( 0 => int i; i < MAX; i++ ) {
    lamps[i].size( 100, lamps[i].height() );
    lamps[i].position( i * 30, s_total.height() + 50 );
    //lamps[i].width() $ int / 2 +=> w;
    lamps[i] => view.addElement;
}

MAX * 32 => w;

s_total => view.addElement;
s_pulses => view.addElement;
s_bpm => view.addElement;
view.display();

(w, h) => view.size;

int sequence[];

fun void update_lights() {
    for(int i; i < MAX; i++) {
        if(i > sequence.cap() -1) {
            lamps[i].unlight();
        } else {
            if(sequence[i] == true) {
                lamps[i].color(MAUI_LED.red);
            } else {
                lamps[i].color(MAUI_LED.blue);
            }
            lamps[i].light();
        }
    }
}

fun void regenerate() {
    bjorklund(s_pulses.value() $ int, s_total.value() $ int) @=> sequence;
    update_lights();

    for(int i; i < sequence.cap(); i++) {
        chout <= sequence[i];
    }
    chout <= IO.newline();
}

// regenerate the sequence when controls are modified 

fun void ctl1() {
    while(true) {
        s_total => now;
        regenerate();
    }
}

fun void ctl2() {
    while(true) {
        s_pulses => now;
        regenerate();
    }
}


ModalBar bar => dac;
180 => int bpm => s_bpm.value;
1 => int seq_counter;

fun void ctl3() {
    while(true) {
        s_bpm => now;
        s_bpm.value() $ int => bpm;
    }
}

fun void play() {
    regenerate();
    while(seq_counter++) {

        s_pulses.value() $ int => int total;
        seq_counter % (total) => int seqElement;
        chout <= seqElement <= IO.newline();
        update_lights();
        MAUI_LED.green => lamps[seqElement].color;
        if(sequence[seqElement] == 1) {
            .8 => bar.noteOn;
        }
        else {
            .2 => bar.noteOn;            
        }
        (60.0/bpm)::second => now;
    }
}

spork ~ ctl1();
spork ~ ctl2();
spork ~ ctl3();
spork ~ play();

.8 => bar.noteOn;

while(true) 1::second=> now;
