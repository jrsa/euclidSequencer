fun int[] bjorklund(int steps, int pulses) {
    if(pulses > steps) {
        return [9999];
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
MAUI_Slider s_total, s_pulses;

32 => int MAX;

s_total.range( 0, MAX );
s_pulses.range( 0, MAX );
s_total.size( 200, s_total.height() );
s_pulses.size( 200, s_total.height() + s_pulses.height() );

400 +=> h;

"total beats" => s_total.name;
"accent beats" => s_pulses.name;
MAUI_Slider.integerFormat => s_total.displayFormat;
MAUI_Slider.integerFormat => s_pulses.displayFormat;

new MAUI_LED[MAX] @=> MAUI_LED @ lamps[];

for( 0 => int i; i < MAX; i++ ) {
    lamps[i].size( 100, lamps[i].height() );
    lamps[i].position( i * 30, s_total.height() + s_pulses.height() );
    //lamps[i].width() $ int / 2 +=> w;
    lamps[i] => view.addElement;
}

MAX * 30 => w;

s_total => view.addElement;
s_pulses => view.addElement;

(w, h) => view.size;
view.display();

int sequence[];

fun void regenerate() {
    bjorklund(s_pulses.value() $ int, s_total.value() $ int) @=> sequence;

}

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

spork ~ ctl1();
spork ~ ctl2();

while(true) 1::second=> now;
