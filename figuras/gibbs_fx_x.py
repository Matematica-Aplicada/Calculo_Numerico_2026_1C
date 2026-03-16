#!/usr/bin/env python3
"""
Ilustración del fenómeno de Gibbs para f(x) = x en [-pi, pi].

La serie de Fourier de f(x) = x (extendida periódicamente) es:
    f(x) = 2 sum_{k=1}^{infty} (-1)^{k+1} sin(kx) / k

Como f(x) = x no es periódica, su extensión 2pi-periódica tiene
discontinuidades de salto en x = ±pi, y la serie de Fourier parcial
presenta el fenómeno de Gibbs: oscilaciones del ~9% del salto que
no desaparecen al aumentar N.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x = np.linspace(-np.pi, np.pi, 2000)
f_exact = x.copy()

Ns = [3, 7, 25, 100]
fig, axes = plt.subplots(2, 2, figsize=(10, 7), sharex=True, sharey=True)

for ax, N in zip(axes.flat, Ns):
    # Suma parcial de la serie de Fourier
    S_N = np.zeros_like(x)
    for k in range(1, N + 1):
        S_N += 2 * (-1)**(k + 1) * np.sin(k * x) / k

    ax.plot(x, f_exact, 'k--', linewidth=1.0, label=r'$f(x) = x$')
    ax.plot(x, S_N, 'b-', linewidth=1.2, label=rf'$S_{{{N}}}(x)$')
    
    # Marcar las discontinuidades de la extensión periódica
    ax.plot([-np.pi, -np.pi], [-np.pi, np.pi], 'k--', linewidth=0.5)
    ax.plot([np.pi, np.pi], [-np.pi, np.pi], 'k--', linewidth=0.5)
    
    ax.set_title(rf'$N = {N}$', fontsize=13)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(-np.pi - 0.3, np.pi + 0.3)
    ax.set_ylim(-4.2, 4.2)
    ax.axhline(0, color='gray', linewidth=0.3)
    ax.grid(True, alpha=0.3)

fig.suptitle(
    r'Fenómeno de Gibbs: serie de Fourier de $f(x) = x$ en $[-\pi, \pi]$',
    fontsize=14, y=0.98
)
fig.tight_layout(rect=[0, 0, 1, 0.94])
fig.savefig('figuras/gibbs_fx_x.pdf', bbox_inches='tight')
fig.savefig('figuras/gibbs_fx_x.png', bbox_inches='tight', dpi=150)
print("Figuras guardadas en figuras/gibbs_fx_x.pdf y figuras/gibbs_fx_x.png")
