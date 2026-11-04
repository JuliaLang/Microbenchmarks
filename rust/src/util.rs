use rand::Rng;
use rand_distr::StandardNormal;
use rand::SeedableRng;
use rand_mt::Mt19937GenRand64;

pub type MTRng = Mt19937GenRand64;

#[inline]
pub fn gen_rng(seed: u64) -> MTRng {
    Mt19937GenRand64::seed_from_u64(seed)
}

pub fn fill_rand<'a, I, T: 'a, R>(a: I, rng: &mut R)
where
    I: IntoIterator<Item=&'a mut T>,
    rand::distributions::Standard: rand::distributions::Distribution<T>,
    R: Rng,
{
    for v in a.into_iter() {
        *v = rng.gen();
    }
}

pub fn fill_randn<'a, I, R>(a: I, rng: &mut R)
where
    I: IntoIterator<Item=&'a mut f64>,
    R: Rng,
{
    for v in a.into_iter() {
        *v = rng.sample(StandardNormal);
    }
}

pub fn myrand<R: Rng>(n: usize, rng: &mut R) -> Vec<f64> {
    let mut d: Vec<f64> = vec![0.; n];
    fill_rand(&mut d, rng);
    d
}
