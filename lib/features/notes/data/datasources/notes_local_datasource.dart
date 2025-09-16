import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteSubjectModel>> getNotesByGrade(int grade);
  Future<List<NoteModel>> getNotesByChapter(String chapterId);
  Future<NoteModel?> getNoteById(String noteId);
  Future<List<NoteModel>> searchNotes(String query);
  Future<List<int>> getAvailableGrades();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  // Dummy data for demonstration
  static final List<NoteSubjectModel> _dummyData = [
    // Grade 10 - Biology
    NoteSubjectModel(
      id: 'bio_10',
      name: 'Biology',
      grade: 10,
      iconName: 'biology',
      chapters: [
        NoteChapterModel(
          id: 'bio_10_ch1',
          name: 'Chemical Reactions and Stoichiometry',
          subjectId: 'bio_10',
          grade: 10,
          notes: [
            NoteModel(
              id: 'bio_10_ch1_n1',
              title: 'Introduction to Chemical Reactions',
              content: '''# Introduction to Chemical Reactions

Chemical reactions are processes in which one or more substances are converted into different substances. These reactions involve the breaking and forming of chemical bonds.

## Types of Chemical Reactions

### 1. Combination Reactions
- Two or more substances combine to form a single product
- General form: A + B → AB
- Example: \\(2H_2 + O_2 → 2H_2O\\)

### 2. Decomposition Reactions
- A single compound breaks down into two or more simpler substances
- General form: AB → A + B
- Example: \\(2H_2O_2 → 2H_2O + O_2\\)

### 3. Displacement Reactions
- One element displaces another in a compound
- General form: A + BC → AC + B
- Example: \\(Zn + CuSO_4 → ZnSO_4 + Cu\\)

## Balancing Chemical Equations

Chemical equations must be balanced to satisfy the law of conservation of mass:

\\[aA + bB → cC + dD\\]

Where a, b, c, and d are stoichiometric coefficients.

### Steps to Balance:
1. Count atoms of each element on both sides
2. Adjust coefficients to balance each element
3. Check that all elements are balanced
4. Ensure coefficients are in lowest whole number ratio

## Practice Problems

**Problem 1:** Balance the equation: \\(Fe + O_2 → Fe_2O_3\\)

**Solution:** \\(4Fe + 3O_2 → 2Fe_2O_3\\)

**Problem 2:** Balance: \\(C_3H_8 + O_2 → CO_2 + H_2O\\)

**Solution:** \\(C_3H_8 + 5O_2 → 3CO_2 + 4H_2O\\)''',
              subjectId: 'bio_10',
              subjectName: 'Biology',
              grade: 10,
              chapterId: 'bio_10_ch1',
              chapterName: 'Chemical Reactions and Stoichiometry',
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              updatedAt: DateTime.now().subtract(const Duration(days: 5)),
              tags: ['reactions', 'stoichiometry', 'balancing'],
            ),
            NoteModel(
              id: 'bio_10_ch1_n2',
              title: 'Stoichiometry Calculations',
              content: '''# Stoichiometry Calculations

Stoichiometry is the calculation of quantities in chemical reactions based on the balanced chemical equation.

## Mole Concept

The mole is the fundamental unit for measuring amount of substance:
- 1 mole = \\(6.022 × 10^{23}\\) particles (Avogadro's number)
- Molar mass = mass of 1 mole of substance (g/mol)

### Key Relationships:
\\[n = \\frac{m}{M} = \\frac{N}{N_A} = \\frac{V}{V_m}\\]

Where:
- n = number of moles
- m = mass (g)
- M = molar mass (g/mol)
- N = number of particles
- \\(N_A\\) = Avogadro's number
- V = volume (L, for gases at STP)
- \\(V_m\\) = molar volume (22.4 L/mol at STP)

## Stoichiometric Calculations

### Step-by-Step Approach:
1. Write balanced chemical equation
2. Identify given and required quantities
3. Convert given quantity to moles
4. Use mole ratio from balanced equation
5. Convert to required units

### Example Problem:
How many grams of \\(CO_2\\) are produced when 25.0 g of \\(C_3H_8\\) burns completely?

**Equation:** \\(C_3H_8 + 5O_2 → 3CO_2 + 4H_2O\\)

**Solution:**
1. Molar mass of \\(C_3H_8\\) = 44.1 g/mol
2. Moles of \\(C_3H_8\\) = 25.0 g ÷ 44.1 g/mol = 0.567 mol
3. From equation: 1 mol \\(C_3H_8\\) → 3 mol \\(CO_2\\)
4. Moles of \\(CO_2\\) = 0.567 mol × 3 = 1.70 mol
5. Mass of \\(CO_2\\) = 1.70 mol × 44.0 g/mol = 74.8 g

## Limiting Reagent

When multiple reactants are present, the limiting reagent determines the amount of product formed.

### Steps to Find Limiting Reagent:
1. Calculate moles of each reactant
2. Determine theoretical yield from each reactant
3. The reactant giving the smallest yield is limiting
4. Calculate actual yield based on limiting reagent''',
              subjectId: 'bio_10',
              subjectName: 'Biology',
              grade: 10,
              chapterId: 'bio_10_ch1',
              chapterName: 'Chemical Reactions and Stoichiometry',
              createdAt: DateTime.now().subtract(const Duration(days: 25)),
              updatedAt: DateTime.now().subtract(const Duration(days: 3)),
              tags: ['stoichiometry', 'mole', 'calculations'],
            ),
          ],
        ),
      ],
    ),

    // Grade 11 - Chemistry
    NoteSubjectModel(
      id: 'chem_11',
      name: 'Chemistry',
      grade: 11,
      iconName: 'chemistry',
      chapters: [
        NoteChapterModel(
          id: 'chem_11_ch1',
          name: 'Atomic Structure and Periodic Properties',
          subjectId: 'chem_11',
          grade: 11,
          notes: [
            NoteModel(
              id: 'chem_11_ch1_n1',
              title: 'Atomic Structure and Electronic Configuration',
              content: '''# Atomic Structure and Electronic Configuration

## Atomic Structure

An atom consists of:
- **Nucleus**: Contains protons (+) and neutrons (neutral)
- **Electron cloud**: Contains electrons (-) in orbitals

### Fundamental Particles:
| Particle | Symbol | Charge | Mass (amu) | Location |
|----------|--------|--------|------------|----------|
| Proton   | p⁺     | +1     | 1.007      | Nucleus  |
| Neutron  | n⁰     | 0      | 1.009      | Nucleus  |
| Electron | e⁻     | -1     | 0.0005     | Orbitals |

## Quantum Numbers

Four quantum numbers describe the state of an electron:

### 1. Principal Quantum Number (n)
- Describes energy level/shell
- Values: n = 1, 2, 3, 4, ...
- Higher n = higher energy, farther from nucleus

### 2. Azimuthal Quantum Number (l)
- Describes subshell/orbital shape
- Values: l = 0 to (n-1)
- s(l=0), p(l=1), d(l=2), f(l=3)

### 3. Magnetic Quantum Number (\\(m_l\\))
- Describes orbital orientation
- Values: \\(m_l\\) = -l to +l
- Number of orbitals = 2l + 1

### 4. Spin Quantum Number (\\(m_s\\))
- Describes electron spin
- Values: \\(m_s\\) = +½ or -½

## Electronic Configuration

### Aufbau Principle
Electrons fill orbitals in order of increasing energy:
1s < 2s < 2p < 3s < 3p < 4s < 3d < 4p < 5s < 4d < 5p...

### Hund's Rule
- Electrons occupy orbitals singly before pairing
- All unpaired electrons have parallel spins

### Pauli Exclusion Principle
- No two electrons can have identical quantum numbers
- Maximum 2 electrons per orbital (opposite spins)

### Examples:
- **Hydrogen (Z=1):** 1s¹
- **Carbon (Z=6):** 1s² 2s² 2p²
- **Oxygen (Z=8):** 1s² 2s² 2p⁴
- **Sodium (Z=11):** 1s² 2s² 2p⁶ 3s¹ or [Ne] 3s¹

## Orbital Shapes

### s-orbitals
- Spherical shape
- Can hold 2 electrons maximum
- Present in all energy levels

### p-orbitals
- Dumbbell shape
- Three orientations: \\(p_x, p_y, p_z\\)
- Can hold 6 electrons maximum
- Present from n=2 onwards

### d-orbitals
- Complex shapes
- Five orientations
- Can hold 10 electrons maximum
- Present from n=3 onwards''',
              subjectId: 'chem_11',
              subjectName: 'Chemistry',
              grade: 11,
              chapterId: 'chem_11_ch1',
              chapterName: 'Atomic Structure and Periodic Properties',
              createdAt: DateTime.now().subtract(const Duration(days: 20)),
              updatedAt: DateTime.now().subtract(const Duration(days: 2)),
              tags: ['atomic structure', 'quantum numbers', 'orbitals'],
            ),
          ],
        ),
        NoteChapterModel(
          id: 'chem_11_ch2',
          name: 'Chemical Bonding',
          subjectId: 'chem_11',
          grade: 11,
          notes: [
            NoteModel(
              id: 'chem_11_ch2_n1',
              title: 'Types of Chemical Bonds',
              content: '''# Types of Chemical Bonds

Chemical bonds are forces that hold atoms together in compounds.

## Ionic Bonds

### Formation:
- Transfer of electrons from metal to non-metal
- Metal loses electrons → cation (+)
- Non-metal gains electrons → anion (-)
- Electrostatic attraction between ions

### Properties:
- High melting and boiling points
- Conduct electricity when molten or dissolved
- Brittle and hard
- Soluble in polar solvents

### Example:
\\(Na + Cl → Na^+ + Cl^- → NaCl\\)

## Covalent Bonds

### Formation:
- Sharing of electrons between non-metals
- Atoms achieve stable electron configuration

### Types:
1. **Single bond**: Share 1 pair of electrons (−)
2. **Double bond**: Share 2 pairs of electrons (=)
3. **Triple bond**: Share 3 pairs of electrons (≡)

### Properties:
- Lower melting and boiling points than ionic
- Poor electrical conductors
- Can be gases, liquids, or soft solids
- Soluble in non-polar solvents

### Examples:
- \\(H_2\\): H−H
- \\(O_2\\): O=O
- \\(N_2\\): N≡N

## Metallic Bonds

### Formation:
- "Sea of electrons" model
- Metal atoms lose valence electrons
- Electrons move freely throughout structure

### Properties:
- Good electrical and thermal conductors
- Malleable and ductile
- Metallic luster
- Variable melting points

## Lewis Structures

Rules for drawing Lewis structures:
1. Count total valence electrons
2. Arrange atoms (least electronegative in center)
3. Connect atoms with single bonds
4. Distribute remaining electrons as lone pairs
5. Form multiple bonds if needed to satisfy octet rule

### Example: \\(CO_2\\)
1. Total electrons: 4 + 2(6) = 16
2. Structure: O−C−O
3. Complete octets: O=C=O

## VSEPR Theory

Valence Shell Electron Pair Repulsion theory predicts molecular geometry:

| Electron Pairs | Geometry | Bond Angle | Example |
|----------------|----------|------------|---------|
| 2 | Linear | 180° | \\(BeCl_2\\) |
| 3 | Trigonal planar | 120° | \\(BF_3\\) |
| 4 | Tetrahedral | 109.5° | \\(CH_4\\) |
| 5 | Trigonal bipyramidal | 90°, 120° | \\(PF_5\\) |
| 6 | Octahedral | 90° | \\(SF_6\\) |''',
              subjectId: 'chem_11',
              subjectName: 'Chemistry',
              grade: 11,
              chapterId: 'chem_11_ch2',
              chapterName: 'Chemical Bonding',
              createdAt: DateTime.now().subtract(const Duration(days: 15)),
              updatedAt: DateTime.now().subtract(const Duration(days: 1)),
              tags: ['bonding', 'ionic', 'covalent', 'metallic', 'VSEPR'],
              isLocked: true,
            ),
          ],
        ),
      ],
    ),

    // Grade 12 - Physics
    NoteSubjectModel(
      id: 'phys_12',
      name: 'Physics',
      grade: 12,
      iconName: 'physics',
      chapters: [
        NoteChapterModel(
          id: 'phys_12_ch1',
          name: 'Acid-Base Equilibria',
          subjectId: 'phys_12',
          grade: 12,
          notes: [
            NoteModel(
              id: 'phys_12_ch1_n1',
              title: 'Acid-Base Theories and pH',
              content: '''# Acid-Base Theories and pH

## Acid-Base Theories

### Arrhenius Theory
- **Acid**: Produces \\(H^+\\) ions in aqueous solution
- **Base**: Produces \\(OH^-\\) ions in aqueous solution
- Limited to aqueous solutions only

### Brønsted-Lowry Theory
- **Acid**: Proton (\\(H^+\\)) donor
- **Base**: Proton (\\(H^+\\)) acceptor
- More general than Arrhenius theory

Example: \\(HCl + NH_3 → NH_4^+ + Cl^-\\)
- HCl is acid (donates \\(H^+\\))
- \\(NH_3\\) is base (accepts \\(H^+\\))

### Lewis Theory
- **Acid**: Electron pair acceptor
- **Base**: Electron pair donor
- Most general theory

## pH and pOH

### pH Scale
\\[pH = -\\log[H^+]\\]

- pH < 7: Acidic
- pH = 7: Neutral
- pH > 7: Basic

### pOH Scale
\\[pOH = -\\log[OH^-]\\]

### Relationship:
\\[pH + pOH = 14\\] (at 25°C)
\\[K_w = [H^+][OH^-] = 1.0 × 10^{-14}\\] (at 25°C)

## Strong vs Weak Acids and Bases

### Strong Acids (complete ionization):
- HCl, HBr, HI, \\(HNO_3\\), \\(H_2SO_4\\), \\(HClO_4\\)
- \\[pH = -\\log[H^+] = -\\log C_{acid}\\]

### Weak Acids (partial ionization):
- \\(CH_3COOH\\), \\(HF\\), \\(H_2CO_3\\)
- Use \\(K_a\\) (acid dissociation constant)

\\[K_a = \\frac{[H^+][A^-]}{[HA]}\\]

### For weak acid calculation:
\\[[H^+] = \\sqrt{K_a × C_{acid}}\\] (when \\(K_a\\) is small)

### Strong Bases (complete ionization):
- Group 1 hydroxides: LiOH, NaOH, KOH, RbOH, CsOH
- Some Group 2 hydroxides: \\(Ca(OH)_2\\), \\(Sr(OH)_2\\), \\(Ba(OH)_2\\)

### Weak Bases (partial ionization):
- \\(NH_3\\), amines
- Use \\(K_b\\) (base dissociation constant)

\\[K_b = \\frac{[BH^+][OH^-]}{[B]}\\]

## Buffer Solutions

Buffers resist changes in pH when small amounts of acid or base are added.

### Composition:
- Weak acid + its conjugate base
- Weak base + its conjugate acid

### Henderson-Hasselbalch Equation:
\\[pH = pK_a + \\log\\frac{[A^-]}{[HA]}\\]

### Example: Acetate buffer
- \\(CH_3COOH/CH_3COO^-\\)
- When acid added: \\(CH_3COO^- + H^+ → CH_3COOH\\)
- When base added: \\(CH_3COOH + OH^- → CH_3COO^- + H_2O\\)

## Calculations

### Example 1: Strong acid pH
Calculate pH of 0.01 M HCl
\\[pH = -\\log(0.01) = 2\\]

### Example 2: Weak acid pH
Calculate pH of 0.1 M \\(CH_3COOH\\) (\\(K_a = 1.8 × 10^{-5}\\))
\\[[H^+] = \\sqrt{1.8 × 10^{-5} × 0.1} = 1.34 × 10^{-3}\\]
\\[pH = -\\log(1.34 × 10^{-3}) = 2.87\\]''',
              subjectId: 'phys_12',
              subjectName: 'Physics',
              grade: 12,
              chapterId: 'phys_12_ch1',
              chapterName: 'Acid-Base Equilibria',
              createdAt: DateTime.now().subtract(const Duration(days: 10)),
              updatedAt: DateTime.now(),
              tags: ['acid-base', 'pH', 'equilibrium', 'buffer'],
              isLocked: true,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<List<NoteSubjectModel>> getNotesByGrade(int grade) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _dummyData.where((subject) => subject.grade == grade).toList();
  }

  @override
  Future<List<NoteModel>> getNotesByChapter(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    for (final subject in _dummyData) {
      for (final chapter in subject.chapters) {
        if (chapter.id == chapterId) {
          return chapter.notes;
        }
      }
    }
    return [];
  }

  @override
  Future<NoteModel?> getNoteById(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (final subject in _dummyData) {
      for (final chapter in subject.chapters) {
        for (final note in chapter.notes) {
          if (note.id == noteId) {
            return note;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final results = <NoteModel>[];
    final lowercaseQuery = query.toLowerCase();

    for (final subject in _dummyData) {
      for (final chapter in subject.chapters) {
        for (final note in chapter.notes) {
          if (note.title.toLowerCase().contains(lowercaseQuery) ||
              note.content.toLowerCase().contains(lowercaseQuery) ||
              note.tags
                  .any((tag) => tag.toLowerCase().contains(lowercaseQuery))) {
            results.add(note);
          }
        }
      }
    }

    return results;
  }

  @override
  Future<List<int>> getAvailableGrades() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final grades = _dummyData.map((subject) => subject.grade).toSet().toList();
    grades.sort();
    return grades;
  }
}
