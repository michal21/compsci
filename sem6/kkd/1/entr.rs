use std::collections::HashMap;
use std::fs::File;
use std::io::*;
use std::process::{Command, Stdio};
use std::result::Result;

fn main() -> Result<(), Error> {
    let mut tbl = Command::new("column")
        .args(&["-t", "-t", "-s", "\t"])
    //.args(&["-N", "entropy,conditional,diff,fname"])
        .stdin(Stdio::piped())
        .spawn()
        .unwrap();
    let tblout = tbl.stdin.as_mut().unwrap();

    for fname in std::env::args().skip(1) {
        let f = File::open(if &fname != "-" { &fname } else { "/dev/stdin" })?;
        let mut f = BufReader::new(f);
        let mut freq: HashMap<u8, usize> = HashMap::new();
        let mut cfreq: HashMap<(u8, u8), usize> = HashMap::new();
        let mut length = 0;
        let mut c = 0;

        loop {
            let buf = f.fill_buf()?;
            let bl = buf.len();
            if bl == 0 {
                break;
            }

            for b in buf {
                *freq.entry(*b).or_insert(0) += 1;
                *cfreq.entry((c, *b)).or_insert(0) += 1;
                c = *b;
            }

            f.consume(bl);
            length += bl;
        }

        let mut entr: f64 = 0.;
        let mut centr: f64 = 0.;

        for (b, n) in &freq {
            let p = (*n as f64) / (length as f64);
            entr -= p * p.log2();
            let mut pr: f64 = 0.;
            for (cs, nn) in &cfreq {
                if cs.0 == *b {
                    let np = (*nn as f64 / length as f64) / p;
                    pr -= np * np.log2();
                }
            }
            centr += p * pr;
        }

        let s = format!("{}\t{}\t{}\t{}\n", entr, centr, (entr - centr).abs(), fname);
        tblout.write_all(s.as_bytes()).unwrap();
    }

    Ok(())
}
