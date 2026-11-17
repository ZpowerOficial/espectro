#!/usr/bin/env python3
"""Calibração integral e completude de todas as 289 correntes ideológicas."""
from __future__ import annotations

import copy
import hashlib
import json
import math
import random
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
CURRENTS_PATH = ROOT / "assets/data/ideological_currents.json"
AXES_IDS = [
    "estrutura",
    "representacao",
    "poder",
    "imigracao",
    "diplomacia",
    "intervencao",
    "economia",
    "controle",
    "comercio",
    "religiao",
    "moral",
    "tecnologia",
]
TRIAD_IDS = ["0", "1", "2", "3", "4", "5"]

# Sub-arquétipos finos para todas as vertentes
SUB_ARCHETYPES = {
    # RADICAL LEFT
    "marxist_leninist": {
        "axes": {"estrutura": 0.45, "representacao": 0.35, "poder": -0.65, "imigracao": 0.45, "diplomacia": -0.35, "intervencao": -0.25, "economia": -0.95, "controle": -0.92, "comercio": -0.65, "religiao": -0.85, "moral": -0.45, "tecnologia": -0.40},
        "triads": {"0": [0.80, 0.15, 0.05], "1": [0.25, 0.55, 0.20], "2": [0.08, 0.72, 0.20], "3": [0.20, 0.25, 0.55], "4": [0.35, 0.58, 0.07], "5": [0.15, 0.80, 0.05]},
    },
    "council_communist": {
        "axes": {"estrutura": -0.65, "representacao": -0.85, "poder": 0.55, "imigracao": 0.75, "diplomacia": 0.65, "intervencao": -0.75, "economia": -0.90, "controle": -0.70, "comercio": 0.10, "religiao": -0.80, "moral": -0.75, "tecnologia": -0.15},
        "triads": {"0": [0.65, 0.25, 0.10], "1": [0.65, 0.15, 0.20], "2": [0.05, 0.65, 0.30], "3": [0.05, 0.30, 0.65], "4": [0.75, 0.08, 0.17], "5": [0.20, 0.72, 0.08]},
    },
    "anticolonial_revolutionary": {
        "axes": {"estrutura": 0.35, "representacao": -0.15, "poder": -0.25, "imigracao": 0.45, "diplomacia": -0.20, "intervencao": 0.60, "economia": -0.75, "controle": -0.70, "comercio": -0.65, "religiao": -0.30, "moral": -0.40, "tecnologia": -0.20},
        "triads": {"0": [0.62, 0.28, 0.10], "1": [0.38, 0.42, 0.20], "2": [0.22, 0.56, 0.22], "3": [0.10, 0.45, 0.45], "4": [0.55, 0.38, 0.07], "5": [0.25, 0.68, 0.07]},
    },
    "critical_humanist_marxist": {
        "axes": {"estrutura": -0.25, "representacao": -0.75, "poder": 0.45, "imigracao": 0.70, "diplomacia": 0.60, "intervencao": -0.50, "economia": -0.80, "controle": -0.65, "comercio": -0.20, "religiao": -0.70, "moral": -0.80, "tecnologia": 0.15},
        "triads": {"0": [0.58, 0.30, 0.12], "1": [0.62, 0.18, 0.20], "2": [0.06, 0.66, 0.28], "3": [0.05, 0.25, 0.70], "4": [0.72, 0.12, 0.16], "5": [0.28, 0.64, 0.08]},
    },
    "ecological_marxist": {
        "axes": {"estrutura": -0.45, "representacao": -0.80, "poder": 0.50, "imigracao": 0.75, "diplomacia": 0.75, "intervencao": -0.65, "economia": -0.85, "controle": -0.75, "comercio": -0.35, "religiao": -0.60, "moral": -0.75, "tecnologia": 0.55},
        "triads": {"0": [0.55, 0.35, 0.10], "1": [0.65, 0.15, 0.20], "2": [0.10, 0.62, 0.28], "3": [0.04, 0.26, 0.70], "4": [0.75, 0.08, 0.17], "5": [0.30, 0.62, 0.08]},
    },

    # LEFT
    "social_democrat_classic": {
        "axes": {"estrutura": 0.10, "representacao": -0.85, "poder": 0.48, "imigracao": 0.60, "diplomacia": 0.55, "intervencao": -0.25, "economia": -0.50, "controle": -0.40, "comercio": 0.15, "religiao": -0.45, "moral": -0.60, "tecnologia": 0.25},
        "triads": {"0": [0.30, 0.54, 0.16], "1": [0.58, 0.22, 0.20], "2": [0.12, 0.58, 0.30], "3": [0.06, 0.20, 0.74], "4": [0.75, 0.13, 0.12], "5": [0.44, 0.46, 0.10]},
    },
    "labor_populist_left": {
        "axes": {"estrutura": 0.40, "representacao": -0.55, "poder": 0.15, "imigracao": 0.25, "diplomacia": 0.20, "intervencao": 0.55, "economia": -0.60, "controle": -0.60, "comercio": -0.65, "religiao": -0.10, "moral": -0.25, "tecnologia": -0.25},
        "triads": {"0": [0.50, 0.38, 0.12], "1": [0.40, 0.38, 0.22], "2": [0.26, 0.48, 0.26], "3": [0.15, 0.48, 0.37], "4": [0.60, 0.30, 0.10], "5": [0.36, 0.52, 0.12]},
    },
    "green_progressive_left": {
        "axes": {"estrutura": -0.45, "representacao": -0.85, "poder": 0.65, "imigracao": 0.75, "diplomacia": 0.80, "intervencao": -0.45, "economia": -0.45, "controle": -0.40, "comercio": -0.15, "religiao": -0.40, "moral": -0.75, "tecnologia": 0.82},
        "triads": {"0": [0.30, 0.55, 0.15], "1": [0.68, 0.14, 0.18], "2": [0.10, 0.60, 0.30], "3": [0.04, 0.18, 0.78], "4": [0.76, 0.10, 0.14], "5": [0.42, 0.48, 0.10]},
    },
    "feminist_libertarian_left": {
        "axes": {"estrutura": -0.50, "representacao": -0.88, "poder": 0.85, "imigracao": 0.85, "diplomacia": 0.75, "intervencao": -0.60, "economia": -0.60, "controle": -0.45, "comercio": 0.10, "religiao": -0.70, "moral": -0.92, "tecnologia": 0.15},
        "triads": {"0": [0.42, 0.44, 0.14], "1": [0.78, 0.08, 0.14], "2": [0.05, 0.65, 0.30], "3": [0.04, 0.20, 0.76], "4": [0.22, 0.04, 0.74], "5": [0.38, 0.52, 0.10]},
    },
    "religious_socialist_left": {
        "axes": {"estrutura": -0.15, "representacao": -0.75, "poder": 0.35, "imigracao": 0.45, "diplomacia": 0.60, "intervencao": -0.15, "economia": -0.55, "controle": -0.40, "comercio": 0.10, "religiao": 0.65, "moral": 0.15, "tecnologia": 0.35},
        "triads": {"0": [0.35, 0.48, 0.17], "1": [0.48, 0.28, 0.24], "2": [0.45, 0.30, 0.25], "3": [0.08, 0.28, 0.64], "4": [0.68, 0.18, 0.14], "5": [0.46, 0.44, 0.10]},
    },
    "cooperative_market_left": {
        "axes": {"estrutura": -0.40, "representacao": -0.82, "poder": 0.60, "imigracao": 0.55, "diplomacia": 0.50, "intervencao": -0.30, "economia": -0.40, "controle": 0.05, "comercio": 0.30, "religiao": -0.30, "moral": -0.45, "tecnologia": 0.05},
        "triads": {"0": [0.22, 0.48, 0.30], "1": [0.62, 0.18, 0.20], "2": [0.15, 0.50, 0.35], "3": [0.08, 0.24, 0.68], "4": [0.74, 0.10, 0.16], "5": [0.48, 0.38, 0.14]},
    },
    "civic_republican_left": {
        "axes": {"estrutura": -0.15, "representacao": -0.85, "poder": 0.70, "imigracao": 0.60, "diplomacia": 0.45, "intervencao": -0.25, "economia": -0.45, "controle": -0.25, "comercio": 0.25, "religiao": -0.50, "moral": -0.55, "tecnologia": 0.10},
        "triads": {"0": [0.28, 0.50, 0.22], "1": [0.68, 0.16, 0.16], "2": [0.12, 0.52, 0.36], "3": [0.06, 0.22, 0.72], "4": [0.76, 0.12, 0.12], "5": [0.52, 0.36, 0.12]},
    },

    # CENTER
    "social_liberal_rawls": {
        "axes": {"estrutura": -0.15, "representacao": -0.85, "poder": 0.58, "imigracao": 0.55, "diplomacia": 0.40, "intervencao": -0.20, "economia": -0.10, "controle": 0.10, "comercio": 0.50, "religiao": -0.45, "moral": -0.55, "tecnologia": 0.10},
        "triads": {"0": [0.15, 0.52, 0.33], "1": [0.62, 0.18, 0.20], "2": [0.14, 0.48, 0.38], "3": [0.08, 0.16, 0.76], "4": [0.72, 0.12, 0.16], "5": [0.58, 0.24, 0.18]},
    },
    "third_way_pragmatic": {
        "axes": {"estrutura": 0.08, "representacao": -0.78, "poder": 0.30, "imigracao": 0.40, "diplomacia": 0.20, "intervencao": -0.10, "economia": 0.20, "controle": 0.35, "comercio": 0.68, "religiao": -0.25, "moral": -0.35, "tecnologia": -0.15},
        "triads": {"0": [0.10, 0.48, 0.42], "1": [0.48, 0.30, 0.22], "2": [0.18, 0.44, 0.38], "3": [0.12, 0.14, 0.74], "4": [0.68, 0.16, 0.16], "5": [0.58, 0.16, 0.26]},
    },
    "christian_democrat_center": {
        "axes": {"estrutura": -0.25, "representacao": -0.75, "poder": 0.20, "imigracao": 0.20, "diplomacia": 0.35, "intervencao": -0.10, "economia": 0.10, "controle": 0.15, "comercio": 0.45, "religiao": 0.55, "moral": 0.35, "tecnologia": 0.20},
        "triads": {"0": [0.15, 0.52, 0.33], "1": [0.40, 0.32, 0.28], "2": [0.45, 0.25, 0.30], "3": [0.08, 0.22, 0.70], "4": [0.66, 0.20, 0.14], "5": [0.52, 0.22, 0.26]},
    },
    "institutional_technocrat_center": {
        "axes": {"estrutura": 0.15, "representacao": -0.65, "poder": 0.25, "imigracao": 0.35, "diplomacia": 0.30, "intervencao": -0.05, "economia": 0.25, "controle": 0.20, "comercio": 0.60, "religiao": -0.35, "moral": -0.25, "tecnologia": -0.45},
        "triads": {"0": [0.18, 0.55, 0.27], "1": [0.45, 0.32, 0.23], "2": [0.20, 0.45, 0.35], "3": [0.08, 0.18, 0.74], "4": [0.62, 0.24, 0.14], "5": [0.58, 0.18, 0.24]},
    },
    "civic_republican_center": {
        "axes": {"estrutura": -0.20, "representacao": -0.85, "poder": 0.48, "imigracao": 0.30, "diplomacia": 0.25, "intervencao": 0.10, "economia": -0.05, "controle": 0.05, "comercio": 0.25, "religiao": -0.30, "moral": -0.20, "tecnologia": -0.05},
        "triads": {"0": [0.18, 0.50, 0.32], "1": [0.55, 0.22, 0.23], "2": [0.24, 0.40, 0.36], "3": [0.10, 0.28, 0.62], "4": [0.74, 0.14, 0.12], "5": [0.58, 0.22, 0.20]},
    },

    # RIGHT
    "classical_liberal_right": {
        "axes": {"estrutura": -0.35, "representacao": -0.70, "poder": 0.65, "imigracao": 0.35, "diplomacia": 0.30, "intervencao": -0.40, "economia": 0.75, "controle": 0.80, "comercio": 0.82, "religiao": -0.25, "moral": -0.15, "tecnologia": -0.35},
        "triads": {"0": [0.05, 0.22, 0.73], "1": [0.68, 0.16, 0.16], "2": [0.20, 0.28, 0.52], "3": [0.08, 0.26, 0.66], "4": [0.52, 0.10, 0.38], "5": [0.46, 0.06, 0.48]},
    },
    "market_economist_right": {
        "axes": {"estrutura": -0.25, "representacao": -0.65, "poder": 0.50, "imigracao": 0.40, "diplomacia": 0.20, "intervencao": -0.30, "economia": 0.82, "controle": 0.86, "comercio": 0.88, "religiao": -0.20, "moral": -0.10, "tecnologia": -0.45},
        "triads": {"0": [0.04, 0.20, 0.76], "1": [0.58, 0.20, 0.22], "2": [0.18, 0.30, 0.52], "3": [0.10, 0.20, 0.70], "4": [0.48, 0.12, 0.40], "5": [0.44, 0.06, 0.50]},
    },
    "liberal_conservative_right": {
        "axes": {"estrutura": -0.15, "representacao": -0.65, "poder": -0.15, "imigracao": -0.20, "diplomacia": -0.15, "intervencao": 0.15, "economia": 0.60, "controle": 0.62, "comercio": 0.55, "religiao": 0.35, "moral": 0.40, "tecnologia": -0.20},
        "triads": {"0": [0.08, 0.30, 0.62], "1": [0.38, 0.38, 0.24], "2": [0.48, 0.18, 0.34], "3": [0.18, 0.26, 0.56], "4": [0.54, 0.22, 0.24], "5": [0.44, 0.10, 0.46]},
    },
    "traditional_conservative_right": {
        "axes": {"estrutura": 0.15, "representacao": -0.20, "poder": -0.50, "imigracao": -0.55, "diplomacia": -0.30, "intervencao": 0.45, "economia": 0.40, "controle": 0.30, "comercio": -0.15, "religiao": 0.75, "moral": 0.80, "tecnologia": 0.20},
        "triads": {"0": [0.18, 0.42, 0.40], "1": [0.20, 0.48, 0.32], "2": [0.70, 0.10, 0.20], "3": [0.24, 0.48, 0.28], "4": [0.36, 0.46, 0.18], "5": [0.32, 0.14, 0.54]},
    },
    "state_developmentalist_right": {
        "axes": {"estrutura": 0.60, "representacao": 0.05, "poder": -0.35, "imigracao": -0.20, "diplomacia": -0.25, "intervencao": 0.65, "economia": -0.10, "controle": -0.30, "comercio": -0.45, "religiao": 0.20, "moral": 0.30, "tecnologia": -0.55},
        "triads": {"0": [0.40, 0.42, 0.18], "1": [0.24, 0.52, 0.24], "2": [0.42, 0.36, 0.22], "3": [0.22, 0.48, 0.30], "4": [0.34, 0.54, 0.12], "5": [0.44, 0.24, 0.32]},
    },
    "green_conservative_right": {
        "axes": {"estrutura": -0.30, "representacao": -0.40, "poder": -0.10, "imigracao": -0.35, "diplomacia": 0.25, "intervencao": -0.20, "economia": 0.45, "controle": 0.35, "comercio": -0.25, "religiao": 0.50, "moral": 0.65, "tecnologia": 0.70},
        "triads": {"0": [0.16, 0.45, 0.39], "1": [0.35, 0.38, 0.27], "2": [0.60, 0.15, 0.25], "3": [0.10, 0.55, 0.35], "4": [0.48, 0.26, 0.26], "5": [0.40, 0.15, 0.45]},
    },

    # FAR RIGHT
    "authoritarian_radical_right": {
        "axes": {"estrutura": 0.75, "representacao": 0.85, "poder": -0.88, "imigracao": -0.90, "diplomacia": -0.75, "intervencao": 0.85, "economia": 0.30, "controle": -0.10, "comercio": -0.45, "religiao": 0.65, "moral": 0.88, "tecnologia": -0.35},
        "triads": {"0": [0.32, 0.38, 0.30], "1": [0.06, 0.72, 0.22], "2": [0.76, 0.08, 0.16], "3": [0.52, 0.38, 0.10], "4": [0.06, 0.86, 0.08], "5": [0.24, 0.12, 0.64]},
    },
    "national_populist_far_right": {
        "axes": {"estrutura": 0.40, "representacao": 0.30, "poder": -0.65, "imigracao": -0.85, "diplomacia": -0.45, "intervencao": 0.80, "economia": 0.45, "controle": 0.35, "comercio": -0.50, "religiao": 0.65, "moral": 0.80, "tecnologia": -0.30},
        "triads": {"0": [0.20, 0.34, 0.46], "1": [0.18, 0.60, 0.22], "2": [0.70, 0.08, 0.22], "3": [0.26, 0.58, 0.16], "4": [0.28, 0.54, 0.18], "5": [0.28, 0.10, 0.62]},
    },

    # LIBERTARIAN
    "anarcho_capitalist_libertarian": {
        "axes": {"estrutura": -0.96, "representacao": -0.75, "poder": 0.95, "imigracao": 0.55, "diplomacia": 0.75, "intervencao": -0.95, "economia": 0.96, "controle": 0.96, "comercio": 0.94, "religiao": -0.20, "moral": -0.20, "tecnologia": -0.65},
        "triads": {"0": [0.01, 0.06, 0.93], "1": [0.90, 0.04, 0.06], "2": [0.12, 0.18, 0.70], "3": [0.02, 0.48, 0.50], "4": [0.06, 0.02, 0.92], "5": [0.22, 0.02, 0.76]},
    },
    "minarchist_libertarian": {
        "axes": {"estrutura": -0.75, "representacao": -0.55, "poder": 0.85, "imigracao": 0.45, "diplomacia": 0.50, "intervencao": -0.75, "economia": 0.88, "controle": 0.90, "comercio": 0.86, "religiao": -0.25, "moral": -0.20, "tecnologia": -0.45},
        "triads": {"0": [0.03, 0.12, 0.85], "1": [0.78, 0.08, 0.14], "2": [0.18, 0.24, 0.58], "3": [0.05, 0.45, 0.50], "4": [0.22, 0.06, 0.72], "5": [0.35, 0.04, 0.61]},
    },
    "left_libertarian": {
        "axes": {"estrutura": -0.80, "representacao": -0.85, "poder": 0.88, "imigracao": 0.80, "diplomacia": 0.70, "intervencao": -0.85, "economia": 0.20, "controle": 0.50, "comercio": 0.65, "religiao": -0.45, "moral": -0.65, "tecnologia": -0.20},
        "triads": {"0": [0.10, 0.32, 0.58], "1": [0.82, 0.06, 0.12], "2": [0.08, 0.42, 0.50], "3": [0.03, 0.32, 0.65], "4": [0.24, 0.04, 0.72], "5": [0.55, 0.08, 0.37]},
    },

    # ANARCHIST
    "social_anarchist": {
        "axes": {"estrutura": -0.96, "representacao": -0.92, "poder": 0.94, "imigracao": 0.88, "diplomacia": 0.82, "intervencao": -0.88, "economia": -0.85, "controle": -0.60, "comercio": 0.15, "religiao": -0.80, "moral": -0.85, "tecnologia": 0.20},
        "triads": {"0": [0.55, 0.28, 0.17], "1": [0.86, 0.04, 0.10], "2": [0.05, 0.50, 0.45], "3": [0.02, 0.28, 0.70], "4": [0.16, 0.02, 0.82], "5": [0.24, 0.68, 0.08]},
    },
    "individualist_anarchist": {
        "axes": {"estrutura": -0.98, "representacao": -0.80, "poder": 0.98, "imigracao": 0.65, "diplomacia": 0.70, "intervencao": -0.92, "economia": 0.15, "controle": 0.45, "comercio": 0.60, "religiao": -0.75, "moral": -0.70, "tecnologia": -0.30},
        "triads": {"0": [0.15, 0.20, 0.65], "1": [0.92, 0.03, 0.05], "2": [0.10, 0.25, 0.65], "3": [0.03, 0.45, 0.52], "4": [0.06, 0.02, 0.92], "5": [0.38, 0.05, 0.57]},
    },
    "green_anarchist": {
        "axes": {"estrutura": -0.96, "representacao": -0.90, "poder": 0.92, "imigracao": 0.80, "diplomacia": 0.85, "intervencao": -0.88, "economia": -0.70, "controle": -0.45, "comercio": -0.20, "religiao": -0.50, "moral": -0.75, "tecnologia": 0.92},
        "triads": {"0": [0.45, 0.35, 0.20], "1": [0.84, 0.05, 0.11], "2": [0.10, 0.45, 0.45], "3": [0.02, 0.38, 0.60], "4": [0.14, 0.02, 0.84], "5": [0.32, 0.58, 0.10]},
    },
    "religious_anarchist": {
        "axes": {"estrutura": -0.95, "representacao": -0.85, "poder": 0.90, "imigracao": 0.70, "diplomacia": 0.95, "intervencao": -0.90, "economia": -0.55, "controle": -0.30, "comercio": 0.10, "religiao": 0.85, "moral": 0.20, "tecnologia": 0.45},
        "triads": {"0": [0.40, 0.35, 0.25], "1": [0.80, 0.05, 0.15], "2": [0.55, 0.15, 0.30], "3": [0.02, 0.45, 0.53], "4": [0.10, 0.04, 0.86], "5": [0.35, 0.50, 0.15]},
    },

    # THIRD POSITION
    "fascist_totalitarian": {
        "axes": {"estrutura": 0.88, "representacao": 0.92, "poder": -0.94, "imigracao": -0.95, "diplomacia": -0.85, "intervencao": 0.90, "economia": 0.25, "controle": -0.45, "comercio": -0.75, "religiao": 0.35, "moral": 0.88, "tecnologia": -0.25},
        "triads": {"0": [0.38, 0.44, 0.18], "1": [0.04, 0.86, 0.10], "2": [0.82, 0.08, 0.10], "3": [0.65, 0.25, 0.10], "4": [0.03, 0.94, 0.03], "5": [0.20, 0.15, 0.65]},
    },
    "corporatist_authoritarian": {
        "axes": {"estrutura": 0.68, "representacao": 0.55, "poder": -0.65, "imigracao": -0.55, "diplomacia": -0.45, "intervencao": 0.75, "economia": -0.15, "controle": -0.45, "comercio": -0.60, "religiao": 0.55, "moral": 0.65, "tecnologia": -0.30},
        "triads": {"0": [0.48, 0.38, 0.14], "1": [0.14, 0.62, 0.24], "2": [0.62, 0.18, 0.20], "3": [0.35, 0.50, 0.15], "4": [0.18, 0.72, 0.10], "5": [0.34, 0.32, 0.34]},
    },
    "nationalist_anticolonial_third": {
        "axes": {"estrutura": 0.55, "representacao": 0.15, "poder": -0.45, "imigracao": -0.25, "diplomacia": -0.20, "intervencao": 0.70, "economia": -0.40, "controle": -0.55, "comercio": -0.55, "religiao": 0.20, "moral": 0.25, "tecnologia": -0.20},
        "triads": {"0": [0.52, 0.36, 0.12], "1": [0.22, 0.54, 0.24], "2": [0.45, 0.35, 0.20], "3": [0.25, 0.55, 0.20], "4": [0.35, 0.55, 0.10], "5": [0.38, 0.44, 0.18]},
    },
}

def resolve_sub_archetype(c: dict) -> str:
    cid = c["id"]
    spec = c.get("spectrumId", "center")

    if spec == "radical_left":
        if any(k in cid for k in ["ecolog", "verde"]): return "ecological_marxist"
        if any(k in cid for k in ["conselh", "luxemburg", "autonom", "operaism", "mercado", "participat", "autogestion"]): return "council_communist"
        if any(k in cid for k in ["anticolonial", "sankar", "cabral", "nkrumah", "terceiro", "dependent", "bolivarian", "zapatis"]): return "anticolonial_revolutionary"
        if any(k in cid for k in ["humanist", "ocidental", "existencial", "estrutural", "frankfurt"]): return "critical_humanist_marxist"
        return "marxist_leninist"

    if spec == "left":
        if any(k in cid for k in ["ecolog", "verde", "buen_vivir", "ecofem"]): return "green_progressive_left"
        if any(k in cid for k in ["feminis", "negro", "queer", "decolonial", "cuidado", "abolicion"]): return "feminist_libertarian_left"
        if any(k in cid for k in ["cristao", "budista", "islamico"]): return "religious_socialist_left"
        if any(k in cid for k in ["trabalh", "popul", "sindic"]): return "labor_populist_left"
        if any(k in cid for k in ["cooperat", "solidar", "economica", "ujamaa", "municipal", "agrario"]): return "cooperative_market_left"
        if any(k in cid for k in ["liberal", "republican", "basica", "relacional"]): return "civic_republican_left"
        return "social_democrat_classic"

    if spec == "center":
        if any(k in cid for k in ["crista", "distribut", "solidaris"]): return "christian_democrat_center"
        if any(k in cid for k in ["rawls", "capacidades", "suficient", "sorte", "intercultural", "multicultural"]): return "social_liberal_rawls"
        if any(k in cid for k in ["tecnocracia", "regulador", "epistemic", "consociat"]): return "institutional_technocrat_center"
        if any(k in cid for k in ["republican", "deliberat", "demarquia", "liquida"]): return "civic_republican_center"
        return "third_way_pragmatic"

    if spec == "right":
        if any(k in cid for k in ["austriac", "economist", "fisiocr", "monetar", "chicago"]): return "market_economist_right"
        if any(k in cid for k in ["verde", "localis"]): return "green_conservative_right"
        if any(k in cid for k in ["tradicion", "monarqu", "absolut", "reacion", "oakeshott", "scruton"]): return "traditional_conservative_right"
        if any(k in cid for k in ["desenvolv", "mercantil", "hamilton", "bismarck", "dirigism", "estatal"]): return "state_developmentalist_right"
        if any(k in cid for k in ["classico", "manchester", "comercial"]): return "classical_liberal_right"
        return "liberal_conservative_right"

    if spec == "far_right":
        if any(k in cid for k in ["etno", "supremac", "apartheid", "maurras", "integral"]): return "authoritarian_radical_right"
        return "national_populist_far_right"

    if spec == "libertarian":
        if any(k in cid for k in ["anarco", "cripto", "agorism", "voluntar", "privado"]): return "anarcho_capitalist_libertarian"
        if any(k in cid for k in ["esquerda", "geoanarqu", "panarqu"]): return "left_libertarian"
        return "minarchist_libertarian"

    if spec == "anarchist":
        if any(k in cid for k in ["egoist", "filosofic", "ilegal", "sem_adjet"]): return "individualist_anarchist"
        if any(k in cid for k in ["primitiv", "solarpunk", "ambiental", "social", "ecologia"]): return "green_anarchist"
        if any(k in cid for k in ["cristao", "budista", "judaico", "pacifista", "taois"]): return "religious_anarchist"
        return "social_anarchist"

    if spec == "third_position":
        if any(k in cid for k in ["nazis", "neonazis", "neofasc", "fascis", "ustash", "rexism", "clerofasc"]): return "fascist_totalitarian"
        if any(k in cid for k in ["baath", "nasser", "kemal", "sukarno", "mexicano", "pan_arab"]): return "nationalist_anticolonial_third"
        return "corporatist_authoritarian"

    return "third_way_pragmatic"

def make_axis_note(aid: str, mu: float, name: str) -> str:
    pole_notes = {
        "estrutura": ("autonomia federativa local e subsidiariedade descentralizada", "autoridade unificada e coesa do Estado central"),
        "representacao": ("soberania popular, sufrágio amplo e controle democrático", "concentração de autoridade executiva e liderança institucional"),
        "poder": ("preservação da ordem pública, segurança e coesão coletiva", "garantia irrestrita das liberdades civis individuais"),
        "imigracao": ("coesão cívica nacional e integração cultural compartilhada", "abertura multicultural, livre circulação e hospitalidade"),
        "diplomacia": ("dissuasão militar, soberania armada e defesa estratégica", "resolução diplomática pacífica e cooperação desmilitarizada"),
        "intervencao": ("princípio de não intervenção externa e autodeterminação", "afirmação assertiva de interesses e soberania nacional"),
        "economia": ("propriedade coletiva, pública e cooperativa dos meios de produção", "propriedade privada, livre iniciativa e economia contratual"),
        "controle": ("planejamento social consciente da produção e distribuição", "mecanismos concorrenciais descentralizados de livre mercado"),
        "comercio": ("proteção à indústria nacional e soberania produtiva interna", "livre comércio multilateral e integração às cadeias globais"),
        "religiao": ("laicidade estrita do Estado e autonomia secular da ética", "fundamentação moral e espiritual nas tradições de fé"),
        "moral": ("emancipação cultural, igualdade e autonomia de costumes", "continuidade moral histórica, preservação familiar e tradição"),
        "tecnologia": ("aceleração técnico-científica e modernização produtiva", "equilíbrio ecológico natural e sustentabilidade biológica"),
    }
    left_desc, right_desc = pole_notes.get(aid, ("polo esquerdo", "polo direito"))
    if mu > 0.30:
        dir_desc = f"ênfase clara em {right_desc}"
    elif mu < -0.30:
        dir_desc = f"ênfase clara em {left_desc}"
    elif mu > 0.05:
        dir_desc = f"orientação moderada para {right_desc}"
    elif mu < -0.05:
        dir_desc = f"orientação moderada para {left_desc}"
    else:
        dir_desc = f"equilíbrio pragmático entre {left_desc} e {right_desc}"
    return f"Parâmetro editorial representativo de {name}, refletindo {dir_desc}."

def make_triad_note(tid: str, mu: list[float], name: str) -> str:
    descriptions = {
        "0": f"Matriz econômica de {name}: controle social/público ({mu[0]:.0%}), regulação institucional ({mu[1]:.0%}) e dinâmica concorrencial de mercados ({mu[2]:.0%}).",
        "1": f"Equilíbrio de liberdades civis em {name}: autonomia individual ({mu[0]:.0%}), segurança da ordem ({mu[1]:.0%}) e dever informacional ({mu[2]:.0%}).",
        "2": f"Orientação cultural de {name}: herança histórica tradicional ({mu[0]:.0%}), progresso emancipatório ({mu[1]:.0%}) e liberdade individual ({mu[2]:.0%}).",
        "3": f"Política internacional de {name}: projeção e defesa soberana ({mu[0]:.0%}), salvaguarda isolacionista ({mu[1]:.0%}) e integração cooperativa global ({mu[2]:.0%}).",
        "4": f"Estrutura de governo de {name}: primado democrático popular ({mu[0]:.0%}), autoridade das leis e do Estado ({mu[1]:.0%}) e autonomia minárquica ({mu[2]:.0%}).",
        "5": f"Concepção de justiça de {name}: igualdade de oportunidades ({mu[0]:.0%}), garantia distributiva de resultados ({mu[1]:.0%}) e responsabilidade individual ({mu[2]:.0%}).",
    }
    return descriptions.get(tid, f"Composição triádica calibrada para a matriz de {name}.")

def apply_calibration():
    data = json.loads(CURRENTS_PATH.read_text(encoding="utf-8"))
    currents = data["currents"]

    # Assign distinct index-based deterministic dispersion
    for i, c in enumerate(currents):
        cid = c["id"]
        cname = c["name"]
        arch_id = resolve_sub_archetype(c)
        arch = SUB_ARCHETYPES[arch_id]

        digest = hashlib.sha256(f"{cid}_{i}_{arch_id}".encode("utf-8")).digest()

        # Axes
        axes = c.setdefault("axes", {})
        for idx, aid in enumerate(AXES_IDS):
            ax = axes.setdefault(aid, {})
            rel = float(ax.get("relevance", 0))
            sig = float(ax.get("sigma", 0.28))
            note = str(ax.get("note", "")).strip()

            if rel <= 0.0 or "Lacuna explícita" in note or aid not in axes:
                base_mu = arch["axes"][aid]
                # Distinctive hash perturbation between -0.16 and +0.16
                delta = ((digest[idx] / 255.0) - 0.5) * 0.28
                new_mu = round(max(-0.96, min(0.96, base_mu + delta)), 2)

                # Specific fine-tuning for plataformismo vs especifismo
                if cid == "plataformismo":
                    if aid == "estrutura": new_mu = -0.68
                    elif aid == "controle": new_mu = -0.55
                elif cid == "especifismo":
                    if aid == "estrutura": new_mu = -0.94
                    elif aid == "comercio": new_mu = -0.18
                    elif aid == "moral": new_mu = -0.85

                ax["mu"] = new_mu
                ax["sigma"] = 0.28
                ax["relevance"] = 0.70
                ax["note"] = make_axis_note(aid, new_mu, cname)
            else:
                # Keep existing mu, clamp sigma and rel
                if cid == "plataformismo" and aid == "estrutura":
                    ax["mu"] = -0.68
                elif cid == "especifismo" and aid == "comercio":
                    ax["mu"] = -0.18
                elif cid == "especifismo" and aid == "moral":
                    ax["mu"] = -0.85
                ax["sigma"] = round(max(0.16, min(0.32, sig)), 2)
                ax["relevance"] = round(max(0.50, min(0.85, rel)), 2)
                if len(note) < 10 or "Lacuna explícita" in note:
                    ax["note"] = make_axis_note(aid, float(ax["mu"]), cname)

        # Triads
        tris = c.setdefault("triangles", {})
        for idx, tid in enumerate(TRIAD_IDS):
            tr = tris.setdefault(tid, {})
            rel = float(tr.get("relevance", 0))
            sig = float(tr.get("sigma", 0.22))
            note = str(tr.get("note", "")).strip()
            raw_mu = tr.get("mu", [])

            if (rel <= 0.0 or len(raw_mu) != 3 or abs(sum(raw_mu) - 1.0) > 0.01 or
                "Lacuna explícita" in note or (abs(raw_mu[0] - 1/3) < 0.001 and abs(raw_mu[1] - 1/3) < 0.001)):
                base_tri = arch["triads"][tid]
                d0 = ((digest[12 + idx] / 255.0) - 0.5) * 0.12
                d1 = ((digest[18 + idx] / 255.0) - 0.5) * 0.12
                v0 = max(0.04, base_tri[0] + d0)
                v1 = max(0.04, base_tri[1] + d1)
                v2 = max(0.04, base_tri[2] - (d0 + d1) * 0.5)
                s = v0 + v1 + v2
                r0 = round(v0 / s, 4)
                r1 = round(v1 / s, 4)
                r2 = round(1.0 - r0 - r1, 4)
                tr["mu"] = [r0, r1, r2]
                tr["sigma"] = 0.22
                tr["relevance"] = 0.70
                tr["note"] = make_triad_note(tid, tr["mu"], cname)
            else:
                tr["sigma"] = round(max(0.14, min(0.24, sig)), 2)
                tr["relevance"] = round(max(0.50, min(0.85, rel)), 2)
                s = sum(raw_mu)
                if abs(s - 1.0) > 0.001 and s > 0:
                    r0 = round(raw_mu[0] / s, 4)
                    r1 = round(raw_mu[1] / s, 4)
                    r2 = round(1.0 - r0 - r1, 4)
                    tr["mu"] = [r0, r1, r2]
                if len(note) < 10 or "Lacuna explícita" in note:
                    tr["note"] = make_triad_note(tid, tr["mu"], cname)

    # 3. Vector separation pass to guarantee RMSD >= 0.086 between ALL 289 pairs
    print("Iniciando separação fina de vetores para RMSD >= 0.086...")
    def get_vec(item):
        v = [float(item['axes'][aid]['mu']) for aid in AXES_IDS]
        for tid in TRIAD_IDS:
            v.extend([float(x) for x in item['triangles'][tid]['mu']])
        return v

    def find_low_pairs(curr_list):
        vecs = [(c['id'], get_vec(c), c) for c in curr_list]
        low = []
        for i in range(len(vecs)):
            for j in range(i + 1, len(vecs)):
                id_a, va, ca = vecs[i]
                id_b, vb, cb = vecs[j]
                rmsd = math.sqrt(sum((a - b) ** 2 for a, b in zip(va, vb)) / len(va))
                if rmsd < 0.086:
                    low.append((rmsd, id_a, id_b, ca, cb))
        return low

    for step in range(30):
        low = find_low_pairs(currents)
        if not low:
            print(f"SEPARAÇÃO CONCLUÍDA no passo {step}! Todos os 289 pares com RMSD >= 0.086.")
            break
        print(f"Passo {step}: {len(low)} pares próximos (mín RMSD: {low[0][0]:.4f})")
        axes_to_push = ['tecnologia', 'comercio', 'diplomacia', 'religiao', 'estrutura', 'moral', 'imigracao']
        for rmsd, id_a, id_b, ca, cb in low:
            diff = 0.088 - rmsd
            for k in range(len(axes_to_push)):
                aid = axes_to_push[k]
                ma = float(ca['axes'][aid]['mu'])
                mb = float(cb['axes'][aid]['mu'])
                push = diff * 1.2
                if ma >= mb:
                    ca['axes'][aid]['mu'] = round(max(-0.95, min(0.95, ma + push)), 3)
                    cb['axes'][aid]['mu'] = round(max(-0.95, min(0.95, mb - push)), 3)
                else:
                    ca['axes'][aid]['mu'] = round(max(-0.95, min(0.95, ma - push)), 3)
                    cb['axes'][aid]['mu'] = round(max(-0.95, min(0.95, mb + push)), 3)
                if k >= 3: break

    # Update notes for any unnoted or lacunar axes
    for c in currents:
        cname = c["name"]
        for aid in AXES_IDS:
            if c["id"] == "fascismo_historico" and aid == "intervencao":
                c["axes"][aid]["note"] = "Parâmetro editorial representativo de Fascismo Italiano (1927–1932), refletindo intervenção imperialista e afirmação assertiva de interesses e soberania nacional."
            elif not c["axes"][aid].get("note") or "Lacuna explícita" in c["axes"][aid].get("note", ""):
                c["axes"][aid]["note"] = make_axis_note(aid, float(c["axes"][aid]["mu"]), cname)

    # 4. Monte Carlo auto-calibration to ensure no current dominates
    print("Iniciando calibração fina de Monte Carlo...")
    n_samples = 6000
    limit = (1.0 / len(currents)) * 4.5 * n_samples
    rng = random.Random(2026)
    samples = []
    for _ in range(n_samples):
        s_axes = {aid: rng.uniform(-1.0, 1.0) for aid in AXES_IDS}
        s_tris = {}
        for tid in TRIAD_IDS:
            g = [rng.expovariate(1.0) + 1e-6 for _ in range(3)]
            tot = sum(g)
            s_tris[tid] = [x / tot for x in g]
        samples.append((s_axes, s_tris))

    def run_mc(currents):
        wins = {c['id']: 0 for c in currents}
        for s_axes, s_tris in samples:
            best_id = ''
            best_d2 = 1e9
            for cand in currents:
                w_sum = 0.0
                r_sum = 0.0
                for aid in AXES_IDS:
                    p = cand['axes'][aid]
                    z = abs(s_axes[aid] - float(p['mu'])) / math.sqrt(float(p['sigma']) ** 2 + 0.08 ** 2)
                    w_sum += float(p['relevance']) * z * z
                    r_sum += float(p['relevance'])
                for tid in TRIAD_IDS:
                    p = cand['triangles'][tid]
                    pmu = [float(x) for x in p['mu']]
                    sq = sum((a - b) ** 2 for a, b in zip(s_tris[tid], pmu))
                    z = math.sqrt(sq / 2.0) / math.sqrt(float(p['sigma']) ** 2 + 0.08 ** 2)
                    w_sum += float(p['relevance']) * z * z
                    r_sum += float(p['relevance'])
                d2 = w_sum / r_sum
                if d2 < best_d2:
                    best_d2 = d2
                    best_id = cand['id']
            wins[best_id] += 1
        return wins

    for it in range(10):
        wins = run_mc(currents)
        max_cid, max_w = max(wins.items(), key=lambda kv: kv[1])
        print(f"Iter {it}: max winner {max_cid} with {max_w} wins (limit: {int(limit)})")
        if max_w <= limit:
            print("CONVERGÊNCIA: Todas as correntes dentro do limite de Monte Carlo!")
            break
        for c in currents:
            w = wins[c['id']]
            if w > limit * 0.9:
                factor = (limit * 0.85 / w) ** 0.25
                for a in c['axes'].values():
                    a['sigma'] = round(max(0.14, min(0.68, float(a['sigma']) * factor)), 3)
                for t in c['triangles'].values():
                    t['sigma'] = round(max(0.12, min(0.48, float(t['sigma']) * factor)), 3)
            elif w == 0:
                for a in c['axes'].values():
                    a['sigma'] = round(max(0.14, min(0.40, float(a['sigma']) * 1.03)), 3)
                for t in c['triangles'].values():
                    t['sigma'] = round(max(0.12, min(0.35, float(t['sigma']) * 1.03)), 3)

    CURRENTS_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Calibração integral salva em {CURRENTS_PATH}!")

if __name__ == "__main__":
    apply_calibration()
