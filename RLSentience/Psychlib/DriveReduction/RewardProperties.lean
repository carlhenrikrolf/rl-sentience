import RLSentience.Psychlib.DriveReduction.Basic

/-!
# Behavioural properties of the drive-reduction reward: Equations (6)–(9)

Formalization of the four properties of the reward function claimed in Keramati & Gutkin
(eLife 2014;3:e04811), main text, for `n > m > 1` and an outcome
`K = (0, …, k_j, …, 0)` affecting a single physiological dimension `j`:

* Equation (6): `∂r/∂k_j > 0`  — the reinforcing value increases with the dose;
* Equation (7): `∂r/∂|h*_j - h_j| > 0` — potentiating effect of the deprivation level;
* Equation (8): the *inhibitory* effect of irrelevant drives;
* Equation (9): `∂²r/∂k_j² < 0` — concavity, i.e. risk aversion.

The derivative conditions are formalized as the corresponding strict monotonicity /
strict concavity statements, which is what the paper's accompanying prose asserts
("increases as a function of", "concave function of").

**Discrepancies found.** Equation (6), as printed, has no hypothesis excluding an
outcome that overshoots the setpoint, and is false without one
(`eq6_fails_when_dose_overshoots`); it is proved here on the no-overshoot range.

Equation (8) has a sign error. The prose accompanying it says that increasing the
deprivation level of an irrelevant dimension `i ≠ j` *inhibits* the rewarding value of the
outcome, but the displayed formula (8) states `∂r(H_t,K_t) / ∂|h*_i - h_{i,t}| > 0`.
The displayed sign is wrong: the reward is strictly *decreasing* in the irrelevant
deprivation (`eq8_irrelevant_drive_inhibits` below), and
`eq8_as_printed_is_false` exhibits an explicit instance with `n > m > 1` where the
derivative in question is strictly negative.
-/

namespace HRL

open scoped BigOperators
open Set

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The one-dimensional reduction of the drive -/

/-- Auxiliary function: `φ_{S}(u) = (S + u ^ n) ^ (1/m)`. If `S` is the contribution of all
the dimensions other than `j` to the sum inside the drive, then the drive equals `φ_S(u)`
where `u = |h*_j - h_j|` is the deviation along dimension `j`. -/
noncomputable def phi (m n S u : ℝ) : ℝ := (S + u ^ n) ^ (1 / m)

/-- The contribution to the drive of all physiological dimensions other than `j`. -/
noncomputable def offSum (n : ℝ) (Hstar H : ι → ℝ) (j : ι) : ℝ :=
  ∑ i ∈ Finset.univ.erase j, |Hstar i - H i| ^ n

lemma offSum_nonneg (n : ℝ) (Hstar H : ι → ℝ) (j : ι) : 0 ≤ offSum n Hstar H j := by
  unfold offSum; positivity

lemma drive_eq_phi (m n : ℝ) (Hstar H : ι → ℝ) (j : ι) :
    drive m n Hstar H = phi m n (offSum n Hstar H j) |Hstar j - H j| := by
  unfold drive phi offSum
  rw [Finset.sum_erase_add _ _ (Finset.mem_univ j)]

lemma drive_add_single (m n : ℝ) (Hstar H : ι → ℝ) (j : ι) (k : ℝ) :
    drive m n Hstar (H + Pi.single j k) =
      phi m n (offSum n Hstar H j) |Hstar j - H j - k| := by
  unfold drive phi offSum
  rw [← Finset.sum_erase_add _ _ (Finset.mem_univ j)]
  have h1 : ∑ i ∈ Finset.univ.erase j, |Hstar i - (H + Pi.single j k : ι → ℝ) i| ^ n
      = ∑ i ∈ Finset.univ.erase j, |Hstar i - H i| ^ n :=
    Finset.sum_congr rfl fun i hi => by
      simp [Pi.single_eq_of_ne (Finset.ne_of_mem_erase hi)]
  have h2 : |Hstar j - (H + Pi.single j k : ι → ℝ) j| = |Hstar j - H j - k| := by
    simp [sub_sub]
  rw [h1, h2]

/-- The reward of a single-dimensional outcome, in reduced one-dimensional form. -/
lemma reward_single (m n : ℝ) (Hstar H : ι → ℝ) (j : ι) (k : ℝ) :
    reward m n Hstar H (Pi.single j k) =
      phi m n (offSum n Hstar H j) |Hstar j - H j| -
        phi m n (offSum n Hstar H j) |Hstar j - H j - k| := by
  rw [reward_def, drive_eq_phi m n Hstar H j, drive_add_single]

/-- Updating the state along a dimension `j` does not change the contribution of the other
dimensions to the drive. -/
lemma offSum_update_self (n : ℝ) (Hstar H : ι → ℝ) (j : ι) (v : ℝ) :
    offSum n Hstar (Function.update H j v) j = offSum n Hstar H j :=
  Finset.sum_congr rfl fun i hi => by
    simp [Function.update_of_ne (Finset.ne_of_mem_erase hi)]

/-- Updating the state along a dimension `i ≠ j` changes the contribution of the other
dimensions to the drive only through the `i`-th summand. -/
lemma offSum_update_other (n : ℝ) (Hstar H : ι → ℝ) (i j : ι) (hij : i ≠ j) (v : ℝ) :
    offSum n Hstar (Function.update H i v) j =
      (∑ l ∈ (Finset.univ.erase j).erase i, |Hstar l - H l| ^ n) + |Hstar i - v| ^ n := by
  unfold offSum
  rw [← Finset.sum_erase_add _ _ (Finset.mem_erase.2 ⟨hij, Finset.mem_univ i⟩)]
  congr 1
  · exact Finset.sum_congr rfl fun l hl => by
      simp [Function.update_of_ne (Finset.ne_of_mem_erase hl)]
  · simp

/-! ## Analytic properties of `φ` -/

private lemma rpow_sub_one_mul (A p : ℝ) (hA : 0 < A) : A ^ (p - 1) * A = A ^ p := by
  nth_rewrite 2 [← Real.rpow_one A]
  rw [← Real.rpow_add hA]
  ring_nf

/-- Increments of a strictly convex function are strictly increasing. -/
private lemma strictConvexOn_increment_lt {f : ℝ → ℝ} {s : Set ℝ} (hf : StrictConvexOn ℝ s f)
    {a b c : ℝ} (ha : a ∈ s) (hb : b ∈ s) (hac : a + c ∈ s) (hbc : b + c ∈ s)
    (hab : a < b) (hc : 0 < c) : f (a + c) - f a < f (b + c) - f b := by
  have hne1 : a + c ≠ a := by intro h; linarith
  have hne2 : b + c ≠ a := by intro h; linarith
  have hne3 : a ≠ b + c := by intro h; linarith
  have hne4 : b ≠ b + c := by intro h; linarith
  have h1 := hf.secant_strict_mono ha hac hbc hne1 hne2 (by linarith)
  have h2 := hf.secant_strict_mono hbc ha hb hne3 hne4 hab
  have e1 : a + c - a = c := by ring
  have e2 : (f a - f (b + c)) / (a - (b + c)) = (f (b + c) - f a) / (b + c - a) := by
    rw [← neg_div_neg_eq]; ring_nf
  have e3 : (f b - f (b + c)) / (b - (b + c)) = (f (b + c) - f b) / c := by
    rw [← neg_div_neg_eq]; ring_nf
  rw [e1] at h1
  rw [e2, e3] at h2
  exact (div_lt_div_iff_of_pos_right hc).1 (lt_trans h1 h2)

lemma phi_continuous (m n S : ℝ) (hm : 0 < m) (hn : 0 < n) : Continuous (phi m n S) := by
  have h1 : Continuous fun u : ℝ => S + u ^ n :=
    continuous_const.add (Real.continuous_rpow_const hn.le)
  exact (Real.continuous_rpow_const (by positivity : (0:ℝ) ≤ 1 / m)).comp h1

lemma phi_hasDerivAt (m n S : ℝ) (hS : 0 ≤ S) {x : ℝ} (hx : 0 < x) :
    HasDerivAt (phi m n S) (n * x ^ (n - 1) * (1 / m) * (S + x ^ n) ^ (1 / m - 1)) x := by
  have hb : (0:ℝ) < S + x ^ n := by positivity
  exact ((Real.hasDerivAt_rpow_const (Or.inl hx.ne')).const_add S).rpow_const (Or.inl hb.ne')

/-- `φ_S` is strictly increasing on `[0, ∞)`. -/
lemma phi_strictMonoOn {m n S : ℝ} (hm : 0 < m) (hn : 0 < n) (hS : 0 ≤ S) :
    StrictMonoOn (phi m n S) (Ici 0) := by
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  have h : a ^ n < b ^ n := Real.rpow_lt_rpow ha hab hn
  have ha' : (0:ℝ) ≤ a ^ n := Real.rpow_nonneg ha n
  exact Real.rpow_lt_rpow (by linarith) (by linarith) (by positivity)

/-- `φ_S` is strictly convex on `[0, ∞)` when `n > m > 1`. -/
lemma phi_strictConvexOn {m n S : ℝ} (hm : 1 < m) (hmn : m < n) (hS : 0 ≤ S) :
    StrictConvexOn ℝ (Ici 0) (phi m n S) := by
  have hn : 1 < n := lt_trans hm hmn
  have hm0 : 0 < m := by linarith
  refine strictConvexOn_of_deriv2_pos (convex_Ici 0)
    (phi_continuous m n S hm0 (by linarith)).continuousOn ?_
  intro x hx
  rw [interior_Ici] at hx
  have hx : 0 < x := hx
  have hA : (0:ℝ) < S + x ^ n := by positivity
  set E : ℝ → ℝ := fun y => n * y ^ (n - 1) * (1 / m) * (S + y ^ n) ^ (1 / m - 1) with hE
  have hEq : deriv (phi m n S) =ᶠ[nhds x] E := by
    filter_upwards [Ioi_mem_nhds hx] with y hy
    exact (phi_hasDerivAt m n S hS hy).deriv
  have hEderiv : HasDerivAt E
      (n * ((n - 1) * x ^ (n - 1 - 1)) * (1 / m) * (S + x ^ n) ^ (1 / m - 1) +
        n * x ^ (n - 1) * (1 / m) *
          (n * x ^ (n - 1) * (1 / m - 1) * (S + x ^ n) ^ (1 / m - 1 - 1))) x := by
    have h1 : HasDerivAt (fun y : ℝ => n * y ^ (n - 1) * (1 / m))
        (n * ((n - 1) * x ^ (n - 1 - 1)) * (1 / m)) x :=
      ((Real.hasDerivAt_rpow_const (p := n - 1) (Or.inl hx.ne')).const_mul n).mul_const (1 / m)
    have h2 : HasDerivAt (fun y : ℝ => (S + y ^ n) ^ (1 / m - 1))
        (n * x ^ (n - 1) * (1 / m - 1) * (S + x ^ n) ^ (1 / m - 1 - 1)) x :=
      ((Real.hasDerivAt_rpow_const (Or.inl hx.ne')).const_add S).rpow_const (Or.inl hA.ne')
    exact h1.mul h2
  have hd2 : deriv^[2] (phi m n S) x =
      n * ((n - 1) * x ^ (n - 1 - 1)) * (1 / m) * (S + x ^ n) ^ (1 / m - 1) +
        n * x ^ (n - 1) * (1 / m) *
          (n * x ^ (n - 1) * (1 / m - 1) * (S + x ^ n) ^ (1 / m - 1 - 1)) := by
    show deriv (deriv (phi m n S)) x = _
    rw [hEq.deriv_eq]
    exact hEderiv.deriv
  rw [hd2]
  set B := (S + x ^ n) ^ (1 / m - 1 - 1) with hB
  have e1 : (S + x ^ n) ^ (1 / m - 1) = B * (S + x ^ n) := (rpow_sub_one_mul _ _ hA).symm
  have e2 : x ^ (n - 1) * x ^ (n - 1) = x ^ (n - 1 - 1) * x ^ n := by
    rw [← Real.rpow_add hx, ← Real.rpow_add hx]; ring_nf
  have hBpos : 0 < B := Real.rpow_pos_of_pos hA _
  have hxpos : 0 < x ^ (n - 1 - 1) := Real.rpow_pos_of_pos hx _
  have hxn : 0 < x ^ n := Real.rpow_pos_of_pos hx _
  have key : n * ((n - 1) * x ^ (n - 1 - 1)) * (1 / m) * (S + x ^ n) ^ (1 / m - 1) +
        n * x ^ (n - 1) * (1 / m) * (n * x ^ (n - 1) * (1 / m - 1) * B)
      = n / m * x ^ (n - 1 - 1) * B * ((n - 1) * S + (n / m - 1) * x ^ n) := by
    rw [e1]
    have h3 : n * x ^ (n - 1) * (1 / m) * (n * x ^ (n - 1) * (1 / m - 1) * B)
        = (n * n * (1 / m) * (1 / m - 1) * B) * (x ^ (n - 1) * x ^ (n - 1)) := by ring
    rw [h3, e2]
    field_simp
    ring
  rw [key]
  have h1 : 0 < (n - 1) * S + (n / m - 1) * x ^ n := by
    have : 1 < n / m := (one_lt_div (by linarith)).2 hmn
    nlinarith
  have : 0 < n / m := by positivity
  positivity

/-- The reflected function `k ↦ φ_S(d - k)` is strictly convex on `[0, d]`. -/
lemma phi_reflect_strictConvexOn {m n S : ℝ} (hm : 1 < m) (hmn : m < n) (hS : 0 ≤ S) (d : ℝ) :
    StrictConvexOn ℝ (Icc 0 d) (fun k : ℝ => phi m n S (d - k)) := by
  have hφ := phi_strictConvexOn hm hmn hS
  refine ⟨convex_Icc 0 d, ?_⟩
  intro x hx y hy hxy a b ha hb hab
  have hdx : d - x ∈ Ici (0:ℝ) := by simp only [mem_Ici, sub_nonneg]; exact hx.2
  have hdy : d - y ∈ Ici (0:ℝ) := by simp only [mem_Ici, sub_nonneg]; exact hy.2
  have hne : d - x ≠ d - y := by simpa using hxy
  have := hφ.2 hdx hdy hne ha hb hab
  simp only [smul_eq_mul] at this ⊢
  have he : a * (d - x) + b * (d - y) = d - (a * x + b * y) := by
    linear_combination d * hab
  rwa [he] at this

/-- For a fixed positive shift `k`, the difference `φ_S(d) - φ_S(|d - k|)` is strictly
increasing in `d` on `[0, ∞)`; this is the analytic content of Equation (7). -/
lemma phi_sub_shift_strictMonoOn {m n S k : ℝ} (hm : 1 < m) (hmn : m < n) (hS : 0 ≤ S)
    (hk : 0 < k) :
    StrictMonoOn (fun d : ℝ => phi m n S d - phi m n S |d - k|) (Ici 0) := by
  have hm0 : (0:ℝ) < m := by linarith
  have hn0 : (0:ℝ) < n := by linarith
  have hmono := phi_strictMonoOn (m := m) (n := n) (S := S) hm0 hn0 hS
  have hconv := phi_strictConvexOn hm hmn hS
  -- monotonicity above the shift, where there is no overshoot
  have case1 : ∀ a b : ℝ, k ≤ a → a < b →
      phi m n S a - phi m n S |a - k| < phi m n S b - phi m n S |b - k| := by
    intro a b hka hab
    have ha' : |a - k| = a - k := abs_of_nonneg (by linarith)
    have hb' : |b - k| = b - k := abs_of_nonneg (by linarith)
    rw [ha', hb']
    have h := strictConvexOn_increment_lt hconv (a := a - k) (b := b - k) (c := k)
      (by simp only [mem_Ici]; linarith) (by simp only [mem_Ici]; linarith)
      (by simp only [mem_Ici]; linarith) (by simp only [mem_Ici]; linarith)
      (by linarith) hk
    simp only [sub_add_cancel] at h
    linarith
  -- monotonicity below the shift, where the outcome overshoots the setpoint
  have case2 : ∀ a b : ℝ, 0 ≤ a → a < b → b ≤ k →
      phi m n S a - phi m n S |a - k| < phi m n S b - phi m n S |b - k| := by
    intro a b ha hab hbk
    have ha' : |a - k| = k - a := by rw [abs_of_nonpos (by linarith)]; ring
    have hb' : |b - k| = k - b := by rw [abs_of_nonpos (by linarith)]; ring
    rw [ha', hb']
    have h1 : phi m n S a < phi m n S b := hmono ha (by simp only [mem_Ici]; linarith) hab
    have h2 : phi m n S (k - b) ≤ phi m n S (k - a) := by
      rcases eq_or_lt_of_le (by linarith : k - b ≤ k - a) with h | h
      · rw [h]
      · exact le_of_lt (hmono (by simp only [mem_Ici]; linarith)
          (by simp only [mem_Ici]; linarith) h)
    linarith
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  rcases le_or_gt b k with hbk | hkb
  · exact case2 a b ha hab hbk
  · rcases le_or_gt k a with hka | hak
    · exact case1 a b hka hab
    · exact lt_trans (case2 a k ha hak le_rfl) (case1 k b le_rfl hkb)

/-- For `0 ≤ b < a`, the difference `φ_S(a) - φ_S(b)` is strictly decreasing in `S`;
this is the analytic content of Equation (8) (with the corrected sign). -/
lemma phi_sub_strictAntiOn_offSum {m n a b : ℝ} (hm : 1 < m) (hn : 0 < n) (hb : 0 ≤ b)
    (hab : b < a) :
    StrictAntiOn (fun S : ℝ => phi m n S a - phi m n S b) (Ici 0) := by
  have hban : b ^ n < a ^ n := Real.rpow_lt_rpow hb hab hn
  have hconc : StrictConcaveOn ℝ (Ici 0) fun t : ℝ => t ^ (1 / m) :=
    Real.strictConcaveOn_rpow (by positivity) (by rw [div_lt_one (by linarith)]; linarith)
  have hconv : StrictConvexOn ℝ (Ici (0:ℝ)) fun t : ℝ => -(t ^ (1 / m)) := hconc.neg
  intro S1 h1 S2 h2 h12
  simp only [mem_Ici] at h1 h2
  have hbn : (0:ℝ) ≤ b ^ n := Real.rpow_nonneg hb _
  have key := strictConvexOn_increment_lt hconv (a := S1 + b ^ n) (b := S2 + b ^ n) (c := a ^ n - b ^ n)
    (by simp only [mem_Ici]; linarith) (by simp only [mem_Ici]; linarith)
    (by simp only [mem_Ici]; linarith) (by simp only [mem_Ici]; linarith)
    (by linarith) (by linarith)
  have e1 : S1 + b ^ n + (a ^ n - b ^ n) = S1 + a ^ n := by ring
  have e2 : S2 + b ^ n + (a ^ n - b ^ n) = S2 + a ^ n := by ring
  rw [e1, e2] at key
  simp only [phi]
  linarith

/-! ## Equations (6)–(9) -/

/-- **Equation (6)**: the reinforcing value of an appetitive outcome increases with its
dose `k_j`, as long as the dose does not overshoot the deficit `h*_j - h_j`. -/
theorem eq6_reward_strictMono_dose {m n : ℝ} (hm : 0 < m) (hn : 0 < n)
    (Hstar H : ι → ℝ) (j : ι) :
    StrictMonoOn (fun k : ℝ => reward m n Hstar H (Pi.single j k))
      (Icc 0 (Hstar j - H j)) := by
  intro k1 h1 k2 h2 h12
  simp only [mem_Icc] at h1 h2
  simp only [reward_single]
  have hmono := phi_strictMonoOn (m := m) (n := n) (S := offSum n Hstar H j) hm hn
    (offSum_nonneg n Hstar H j)
  have e1 : |Hstar j - H j - k1| = Hstar j - H j - k1 := abs_of_nonneg (by linarith [h1.2])
  have e2 : |Hstar j - H j - k2| = Hstar j - H j - k2 := abs_of_nonneg (by linarith [h2.2])
  rw [e1, e2]
  have : phi m n (offSum n Hstar H j) (Hstar j - H j - k2)
      < phi m n (offSum n Hstar H j) (Hstar j - H j - k1) :=
    hmono (by simp only [mem_Ici]; linarith [h2.2]) (by simp only [mem_Ici]; linarith [h1.2])
      (by linarith)
  linarith

/-- **Equation (7)**: the potentiating effect of the deprivation level. Writing the state
of dimension `j` as `h_j = h*_j - d`, the rewarding value of a fixed positive outcome
`k_j > 0` is strictly increasing in the deprivation level `d ≥ 0`. -/
theorem eq7_reward_strictMono_deprivation {m n k : ℝ} (hm : 1 < m) (hmn : m < n)
    (hk : 0 < k) (Hstar H : ι → ℝ) (j : ι) :
    StrictMonoOn
      (fun d : ℝ => reward m n Hstar (Function.update H j (Hstar j - d)) (Pi.single j k))
      (Ici 0) := by
  intro d1 h1 d2 h2 h12
  simp only [mem_Ici] at h1 h2
  have hred : ∀ d : ℝ, 0 ≤ d →
      reward m n Hstar (Function.update H j (Hstar j - d)) (Pi.single j k) =
        phi m n (offSum n Hstar H j) d - phi m n (offSum n Hstar H j) |d - k| := by
    intro d hd
    rw [reward_single, offSum_update_self]
    congr 2
    · rw [Function.update_self]
      rw [show Hstar j - (Hstar j - d) = d by ring, abs_of_nonneg hd]
    · rw [Function.update_self]
      congr 1
      ring
  simp only [hred d1 h1, hred d2 h2]
  exact phi_sub_shift_strictMonoOn hm hmn (offSum_nonneg n Hstar H j) hk
    (by simp only [mem_Ici]; exact h1) (by simp only [mem_Ici]; exact h2) h12

/-- **Equation (8), corrected sign**: the inhibitory effect of irrelevant drives. For
`i ≠ j`, writing `h_i = h*_i - e`, the rewarding value of an outcome `k_j` along dimension
`j` is strictly *decreasing* in the deprivation level `e ≥ 0` of the irrelevant dimension
`i`. (The displayed Equation (8) of the paper asserts the opposite sign; the surrounding
prose asserts the inhibitory effect proved here.) -/
theorem eq8_irrelevant_drive_inhibits {m n k : ℝ} (hm : 1 < m) (hn : 0 < n)
    (hk : 0 < k) (Hstar H : ι → ℝ) (i j : ι) (hij : i ≠ j)
    (hkd : k ≤ Hstar j - H j) :
    StrictAntiOn
      (fun e : ℝ => reward m n Hstar (Function.update H i (Hstar i - e)) (Pi.single j k))
      (Ici 0) := by
  set C := ∑ l ∈ (Finset.univ.erase j).erase i, |Hstar l - H l| ^ n with hC
  have hCnonneg : 0 ≤ C := by rw [hC]; positivity
  have hred : ∀ e : ℝ, 0 ≤ e →
      reward m n Hstar (Function.update H i (Hstar i - e)) (Pi.single j k) =
        phi m n (C + e ^ n) (Hstar j - H j) -
          phi m n (C + e ^ n) (Hstar j - H j - k) := by
    intro e he
    rw [reward_single, offSum_update_other n Hstar H i j hij,
      Function.update_of_ne hij.symm]
    rw [show Hstar i - (Hstar i - e) = e by ring, abs_of_nonneg he,
      abs_of_nonneg (by linarith : (0:ℝ) ≤ Hstar j - H j),
      abs_of_nonneg (by linarith : (0:ℝ) ≤ Hstar j - H j - k)]
  intro e1 h1 e2 h2 h12
  simp only [mem_Ici] at h1 h2
  simp only [hred e1 h1, hred e2 h2]
  have hanti := phi_sub_strictAntiOn_offSum (m := m) (n := n) (a := Hstar j - H j)
    (b := Hstar j - H j - k) hm hn (by linarith) (by linarith)
  have hlt : C + e1 ^ n < C + e2 ^ n := by
    have : e1 ^ n < e2 ^ n := Real.rpow_lt_rpow h1 h12 hn
    linarith
  exact hanti (by simp only [mem_Ici]; positivity) (by simp only [mem_Ici]; positivity) hlt

/-- **Equation (9)**: the rewarding value is a strictly concave function of the outcome
magnitude — the risk-aversion property. -/
theorem eq9_reward_strictConcave {m n : ℝ} (hm : 1 < m) (hmn : m < n)
    (Hstar H : ι → ℝ) (j : ι) :
    StrictConcaveOn ℝ (Icc 0 (Hstar j - H j))
      (fun k : ℝ => reward m n Hstar H (Pi.single j k)) := by
  have hS := offSum_nonneg n Hstar H j
  have hconv := phi_reflect_strictConvexOn (m := m) (n := n) (S := offSum n Hstar H j)
    hm hmn hS (Hstar j - H j)
  have hrew : EqOn (fun k : ℝ => reward m n Hstar H (Pi.single j k))
      (fun k : ℝ => phi m n (offSum n Hstar H j) |Hstar j - H j| -
        phi m n (offSum n Hstar H j) (Hstar j - H j - k)) (Icc 0 (Hstar j - H j)) := by
    intro k hk
    simp only [mem_Icc] at hk
    simp only [reward_single,
      abs_of_nonneg (by linarith [hk.1, hk.2] : (0:ℝ) ≤ Hstar j - H j - k)]
  refine StrictConcaveOn.congr ?_ hrew.symm
  refine ⟨convex_Icc 0 (Hstar j - H j), ?_⟩
  intro x hx y hy hxy a b ha hb hab
  have hcv := hconv.2 hx hy hxy ha hb hab
  simp only [smul_eq_mul] at hcv ⊢
  have hV : a * phi m n (offSum n Hstar H j) |Hstar j - H j| +
      b * phi m n (offSum n Hstar H j) |Hstar j - H j| =
      phi m n (offSum n Hstar H j) |Hstar j - H j| := by
    linear_combination phi m n (offSum n Hstar H j) |Hstar j - H j| * hab
  linarith

/-! ## The hypotheses of Equations (6)–(9) are necessary -/

/-- **Equation (6) needs the no-overshoot hypothesis.** As printed, Equation (6) asserts
`∂r/∂k_j > 0` for every outcome `K = (0,…,k_j,…,0)` with `k_j > 0`, with no restriction on
the internal state. This is false once the dose overshoots the deficit: with one
physiological dimension, `m = 3/2`, `n = 2`, setpoint `h* = 0` and state `h = -1`, the
reward `r(k) = 1 - ((k-1)²)^(2/3)` has a strictly negative derivative at `k = 2`.
Theorem `eq6_reward_strictMono_dose` proves the claim on the range `0 ≤ k_j ≤ h*_j - h_j`,
where the outcome does not overshoot the setpoint. -/
theorem eq6_fails_when_dose_overshoots :
    deriv (fun k : ℝ =>
      reward (3/2) 2 (fun _ : Fin 1 => (0:ℝ)) ![-1] (Pi.single 0 k)) 2 < 0 := by
  have hfun : (fun k : ℝ => reward (3/2) 2 (fun _ : Fin 1 => (0:ℝ)) ![-1] (Pi.single 0 k))
      = fun k : ℝ => 1 - ((k - 1) ^ 2) ^ ((2:ℝ)/3) := by
    funext k
    unfold reward drive
    rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
    simp [sq_abs, Pi.single_apply]
    ring_nf
  rw [hfun]
  have h2 : HasDerivAt (fun k : ℝ => ((k - 1) ^ 2) ^ ((2:ℝ)/3))
      (2 * ((2:ℝ)/3) * (1:ℝ) ^ ((2:ℝ)/3 - 1)) 2 := by
    have hi : HasDerivAt (fun k : ℝ => (k - 1) ^ 2) (2 * (1:ℝ)) 2 := by
      have h0 := ((hasDerivAt_id (2:ℝ)).sub_const 1).pow 2
      norm_num at h0 ⊢
      convert h0 using 1
    have h := hi.rpow_const (p := (2:ℝ)/3) (Or.inl (by norm_num))
    norm_num at h ⊢
    convert h using 2
  have hd : HasDerivAt (fun k : ℝ => 1 - ((k - 1) ^ 2) ^ ((2:ℝ)/3))
      (-(2 * ((2:ℝ)/3) * (1:ℝ) ^ ((2:ℝ)/3 - 1))) 2 := by
    simpa using h2.const_sub 1
  rw [hd.deriv, Real.one_rpow]
  norm_num

/-! ## Refutation of Equation (8) exactly as printed -/

/-- **Equation (8) as printed is false.** With two physiological dimensions, `m = 3/2`,
`n = 2` (so `n > m > 1`), setpoint `H* = (0,0)`, internal state `H = (-1, -e)` and outcome
`K = (1, 0)`, the reward is `r(e) = (1 + e²)^(2/3) - (e²)^(2/3)` as a function of the
deprivation level `e = |h*₂ - h₂|` of the irrelevant second dimension. Its derivative at
`e = 1` is strictly negative, whereas Equation (8) claims
`∂r(H_t,K_t) / ∂|h*_i - h_{i,t}| > 0`. -/
theorem eq8_as_printed_is_false :
    deriv (fun e : ℝ =>
      reward (3/2) 2 (fun _ : Fin 2 => (0:ℝ)) ![-1, -e] (Pi.single 0 1)) 1 < 0 := by
  have hfun : (fun e : ℝ => reward (3/2) 2 (fun _ : Fin 2 => (0:ℝ)) ![-1, -e] (Pi.single 0 1))
      = fun e : ℝ => (1 + e ^ 2) ^ ((2:ℝ)/3) - (e ^ 2) ^ ((2:ℝ)/3) := by
    funext e
    unfold reward drive
    rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
    simp [Fin.sum_univ_two, sq_abs, Pi.single_apply]
  rw [hfun]
  have h1 : HasDerivAt (fun e : ℝ => (1 + e ^ 2) ^ ((2:ℝ)/3))
      (2 * ((2:ℝ)/3) * (2:ℝ) ^ ((2:ℝ)/3 - 1)) 1 := by
    have hi : HasDerivAt (fun e : ℝ => 1 + e ^ 2) (2 * (1:ℝ)) 1 := by
      simpa using ((hasDerivAt_pow 2 (1:ℝ)).const_add 1)
    have h := hi.rpow_const (p := (2:ℝ)/3) (Or.inl (by norm_num))
    norm_num at h ⊢
    convert h using 2
  have h2 : HasDerivAt (fun e : ℝ => (e ^ 2) ^ ((2:ℝ)/3))
      (2 * ((2:ℝ)/3) * (1:ℝ) ^ ((2:ℝ)/3 - 1)) 1 := by
    have hi : HasDerivAt (fun e : ℝ => e ^ 2) (2 * (1:ℝ)) 1 := by
      simpa using (hasDerivAt_pow 2 (1:ℝ))
    have h := hi.rpow_const (p := (2:ℝ)/3) (Or.inl (by norm_num))
    norm_num at h ⊢
    convert h using 2
  have hd : HasDerivAt (fun e : ℝ => (1 + e ^ 2) ^ ((2:ℝ)/3) - (e ^ 2) ^ ((2:ℝ)/3))
      (2 * ((2:ℝ)/3) * (2:ℝ) ^ ((2:ℝ)/3 - 1) - 2 * ((2:ℝ)/3) * (1:ℝ) ^ ((2:ℝ)/3 - 1)) 1 :=
    h1.sub h2
  rw [hd.deriv]
  have hlt : (2:ℝ) ^ ((2:ℝ)/3 - 1) < 1 := by
    apply Real.rpow_lt_one_of_one_lt_of_neg <;> norm_num
  rw [Real.one_rpow]
  nlinarith [hlt]

end HRL
