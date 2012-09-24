Ovale.defaut["WARLOCK"] = [[Define(agony 980)
  SpellInfo(agony duration=24 tick=2 )
  SpellAddTargetDebuff(agony agony=1)
Define(backdraft 117896)
Define(blood_fury 20572)
  SpellInfo(blood_fury duration=15 cd=120 )
  SpellAddBuff(blood_fury blood_fury=1)
Define(chaos_bolt 116858)
  SpellInfo(chaos_bolt burningembers=10 )
Define(conflagrate 17962)
  SpellInfo(conflagrate duration=5 )
  SpellAddBuff(conflagrate conflagrate=1)
Define(corruption 172)
  SpellInfo(corruption duration=18 tick=2 )
  SpellAddTargetDebuff(corruption corruption=1)
Define(curse_of_the_elements 1490)
  SpellInfo(curse_of_the_elements duration=300 )
  SpellAddTargetDebuff(curse_of_the_elements aura_of_the_elements=1)
Define(dark_intent 109773)
  SpellInfo(dark_intent duration=3600 )
  SpellAddBuff(dark_intent dark_intent=1)
Define(dark_soul 77801)
  SpellInfo(dark_soul cd=120 )
Define(doom 603)
  SpellInfo(doom duration=60 demonicfury=60 tick=15 stance=1)
  SpellAddTargetDebuff(doom doom=1)
Define(drain_soul 1120)
  SpellInfo(drain_soul duration=12 tick=2 canStopChannelling=1 )
  SpellAddTargetDebuff(drain_soul drain_soul=1)
Define(fel_flame 77799)
Define(felstorm 89751)
  SpellInfo(felstorm duration=6 energy=60 cd=45 )
  SpellAddBuff(felstorm felstorm=1)
Define(fire_and_brimstone 108683)
  SpellInfo(fire_and_brimstone burningembers=10 cd=1 )
  SpellAddBuff(fire_and_brimstone fire_and_brimstone=1)
Define(grimoire_of_sacrifice 108503)
  SpellInfo(grimoire_of_sacrifice duration=3600 cd=120 )
  SpellAddBuff(grimoire_of_sacrifice grimoire_of_sacrifice=1)
Define(hand_of_guldan 105174)
Define(harvest_life 108371)
  SpellInfo(harvest_life duration=6 demonicfury=30 tick=1 )
  SpellAddTargetDebuff(harvest_life harvest_life=1)
Define(haunt 48181)
  SpellInfo(haunt duration=8 shards=1 )
  SpellAddBuff(haunt haunt=1)
Define(havoc 80240)
  SpellInfo(havoc duration=15 cd=25 )
  SpellAddBuff(havoc havoc=1)
Define(hellfire 1949)
  SpellInfo(hellfire duration=14 tick=1 )
  SpellAddTargetDebuff(hellfire hellfire=1)
Define(immolate 348)
  SpellInfo(immolate duration=15 tick=3 )
  SpellAddTargetDebuff(immolate immolate=1)
Define(immolation_aura 104025)
  SpellInfo(immolation_aura duration=10 demonicfury=0 stance=1)
  SpellAddBuff(immolation_aura immolation_aura=1)
Define(incinerate 29722)
Define(life_tap 1454)
  SpellInfo(life_tap mana=-15 )
  SpellAddBuff(life_tap life_tap=1)
Define(malefic_grasp 103103)
  SpellInfo(malefic_grasp duration=4 tick=1 )
  SpellAddTargetDebuff(malefic_grasp malefic_grasp=1)
Define(melee 103988)
  SpellInfo(melee stance=1)
Define(metamorphosis 103958)
  SpellInfo(metamorphosis demonicfury=0 cd=10 )
  SpellAddBuff(metamorphosis metamorphosis=1)
Define(molten_core 122355)
  SpellInfo(molten_core duration=30 )
  SpellAddBuff(molten_core molten_core=1)
Define(rain_of_fire 5740)
  SpellInfo(rain_of_fire duration=6 )
  SpellAddBuff(rain_of_fire rain_of_fire=1)
Define(seed_of_corruption 27243)
  SpellInfo(seed_of_corruption duration=18 tick=3 )
  SpellAddTargetDebuff(seed_of_corruption seed_of_corruption=1)
Define(service_felguard 111898)
  SpellInfo(service_felguard cd=120 )
Define(service_felhunter 111897)
  SpellInfo(service_felhunter cd=120 )
Define(shadow_bolt 686)
  SpellInfo(shadow_bolt demonicfury=40 )
Define(shadowburn 17877)
  SpellInfo(shadowburn burningembers=10 )
Define(shadowflame 47960)
  SpellInfo(shadowflame duration=6 tick=1 )
  SpellAddTargetDebuff(shadowflame shadowflame=1)
Define(soul_fire 6353)
  SpellAddBuff(soul_fire molten_core=-1)
Define(soul_swap 86121)
Define(soulburn 74434)
  SpellInfo(soulburn duration=30 shards=1 cd=1 )
  SpellAddBuff(soulburn soulburn=1)
Define(soulburn_seed_of_corruption 86664)
Define(summon_doomguard 18540)
  SpellInfo(summon_doomguard cd=600 )
Define(summon_felguard 30146)
  SpellInfo(summon_felguard demonicfury=0 )
Define(summon_felhunter 691)
  SpellInfo(summon_felhunter demonicfury=0 )
Define(summon_infernal 1122)
  SpellInfo(summon_infernal cd=600 )
Define(touch_of_chaos 103964)
  SpellInfo(touch_of_chaos demonicfury=40 stance=1)
Define(unstable_affliction 30108)
  SpellInfo(unstable_affliction duration=14 tick=2 )
  SpellAddTargetDebuff(unstable_affliction unstable_affliction=1)
Define(void_ray 115422)
  SpellInfo(void_ray demonicfury=40 )
Define(wrathstorm 115831)
  SpellInfo(wrathstorm duration=6 energy=60 cd=45 )
  SpellAddBuff(wrathstorm wrathstorm=1)
Define(grimoire_of_sacrifice_talent 15)
Define(grimoire_of_service_talent 14)
Define(harvest_life_talent 3)
AddIcon mastery=1 help=main
{
	if not InCombat() 
	{
		if not BuffPresent(spell_power_multiplier any=1) Spell(dark_intent)
		unless pet.CreatureFamily(Felhunter) Spell(summon_felhunter)
	}
	if target.DebuffExpires(magic_vulnerability any=1) Spell(curse_of_the_elements)
	if TalentPoints(grimoire_of_service_talent) Spell(service_felhunter)
	if TalentPoints(grimoire_of_sacrifice_talent) and BuffExpires(grimoire_of_sacrifice) unless pet.CreatureFamily(Felhunter) Spell(summon_felhunter)
	if Enemies() >3 
	{
		if {BuffExpires(soulburn) and not InFlightToTarget(seed_of_corruption) and not target.DebuffPresent(seed_of_corruption) } or {BuffPresent(soulburn) and not target.DebuffPresent(soulburn_seed_of_corruption) and not InFlightToTarget(soulburn_seed_of_corruption) } Spell(seed_of_corruption)
		if not InFlightToTarget(haunt) and target.DebuffRemains(haunt) <CastTime(haunt) +1 and SoulShards() Spell(haunt)
		if ManaPercent() <70 Spell(life_tap)
		if not InFlightToTarget(fel_flame) Spell(fel_flame)
	}
	if BuffPresent(soulburn) Spell(soul_swap)
	if not InFlightToTarget(haunt) and target.DebuffRemains(haunt) <TickTime(haunt) +1 +CastTime(haunt) and SoulShards() Spell(haunt)
	if Enemies() >1 and TimeInCombat() <10 and Glyph(56226) Spell(soul_swap)
	if not InFlightToTarget(haunt) and target.DebuffRemains(haunt) <TickTime(haunt) +1 +CastTime(haunt) and SoulShards() >1 Spell(haunt)
	if target.TicksRemain(agony) <Ticks(agony) /2 and target.DeadIn() >=8 Spell(agony)
	if target.TicksRemain(corruption) <Ticks(corruption) /2 and target.DeadIn() >=6 Spell(corruption)
	if target.TicksRemain(unstable_affliction) <Ticks(unstable_affliction) /2 +1 and target.DeadIn() >=5 Spell(unstable_affliction)
	if target.HealthPercent() <=20 Spell(drain_soul)
	if ManaPercent() <35 Spell(life_tap)
	Spell(malefic_grasp)
	Spell(life_tap)
}
AddIcon mastery=1 help=offgcd
{
	if Enemies() >3 
	{
		if BuffExpires(soulburn) and not target.DebuffPresent(soulburn_seed_of_corruption) and not InFlightToTarget(soulburn_seed_of_corruption) and SoulShards() Spell(soulburn)
	}
	if BuffPresent(dark_soul) and SoulShards() Spell(soulburn)
	if {target.TicksRemain(unstable_affliction) <Ticks(unstable_affliction) /2 or target.TicksRemain(corruption) <Ticks(corruption) /2 or target.TicksRemain(agony) <Ticks(agony) /2 } and target.HealthPercent() <=20 and SoulShards() Spell(soulburn)
}
AddIcon mastery=1 help=moving
{
	if ManaPercent() <80 and ManaPercent() <target.HealthPercent() Spell(life_tap)
	Spell(fel_flame)
}
AddIcon mastery=1 help=aoe
{
	
	{
		Spell(summon_infernal)
	}
}
AddIcon mastery=1 help=cd
{
	 { Item(Trinket0Slot usable=1) Item(Trinket1Slot usable=1) } 
	Spell(blood_fury)
	Spell(dark_soul)
	if TalentPoints(grimoire_of_sacrifice_talent) Spell(grimoire_of_sacrifice)
	
	{
		Spell(summon_doomguard)
	}
	Spell(summon_doomguard)
}
AddIcon mastery=2 help=main
{
	if not InCombat() 
	{
		if not BuffPresent(spell_power_multiplier any=1) Spell(dark_intent)
		unless pet.CreatureFamily(Felguard) Spell(summon_felguard)
	}
	if target.DebuffExpires(magic_vulnerability any=1) Spell(curse_of_the_elements)
	if TalentPoints(grimoire_of_service_talent) Spell(service_felguard)
	if TalentPoints(grimoire_of_sacrifice_talent) and BuffExpires(grimoire_of_sacrifice) unless pet.CreatureFamily(Felguard) Spell(summon_felguard)
	if Enemies() >3 
	{
		if {not target.DebuffPresent(corruption) or target.DebuffRemains(corruption) <TickTime(corruption) } and target.DeadIn() >30 Spell(corruption)
		Spell(hand_of_guldan)
		if {not target.DebuffPresent(doom) or target.DebuffRemains(doom) <40 } and target.DeadIn() >30 Spell(doom)
		if TalentPoints(harvest_life_talent) Spell(harvest_life)
		Spell(life_tap)
	}
	if {not target.DebuffPresent(corruption) or target.DebuffRemains(corruption) <TickTime(corruption) } and target.DeadIn() >=6 Spell(corruption)
	if {not target.DebuffPresent(doom) or target.DebuffRemains(doom) <TickTime(doom) or {target.TicksRemain(doom) +1 <{target.TicksRemain(doom) + Ticks(doom) } and BuffPresent(dark_soul) } } and target.DeadIn() >=30 Spell(doom)
	if target.DebuffRemains(corruption) >20 and BuffExpires(dark_soul) and DemonicFury() <=750 and target.DeadIn() >30 if Stance(1) cancel.Texture(Spell_shadow_demonform)
	if not InFlightToTarget(hand_of_guldan) and target.DebuffRemains(shadowflame) <1 +CastTime(shadow_bolt) Spell(hand_of_guldan)
	if target.DebuffRemains(corruption) <20 Spell(touch_of_chaos)
	if BuffStacks(molten_core) Spell(soul_fire)
	Spell(touch_of_chaos)
	if ManaPercent() <50 Spell(life_tap)
	Spell(shadow_bolt)
	Spell(life_tap)
}
AddIcon mastery=2 help=offgcd
{
	Spell(melee)
	Spell(felstorm)
	Spell(wrathstorm)
	if Enemies() >3 
	{
		if DemonicFury() >=1000 or DemonicFury() >=31 *target.DeadIn() unless Stance(1) Spell(metamorphosis)
	}
	if BuffPresent(dark_soul) or target.DebuffRemains(corruption) <5 or DemonicFury() >=900 or DemonicFury() >=target.DeadIn() *30 unless Stance(1) Spell(metamorphosis)
}
AddIcon mastery=2 help=moving
{
	Spell(fel_flame)
}
AddIcon mastery=2 help=aoe
{
	
	{
		Spell(summon_infernal)
		Spell(immolation_aura)
		if target.DebuffRemains(corruption) <10 Spell(void_ray)
		Spell(void_ray)
		if not TalentPoints(harvest_life_talent) Spell(hellfire)
	}
}
AddIcon mastery=2 help=cd
{
	 { Item(Trinket0Slot usable=1) Item(Trinket1Slot usable=1) } 
	Spell(blood_fury)
	Spell(dark_soul)
	if TalentPoints(grimoire_of_sacrifice_talent) Spell(grimoire_of_sacrifice)
	
	{
		Spell(summon_doomguard)
	}
	Spell(summon_doomguard)
}
AddIcon mastery=3 help=main
{
	if not InCombat() 
	{
		if not BuffPresent(spell_power_multiplier any=1) Spell(dark_intent)
		unless pet.CreatureFamily(Felhunter) Spell(summon_felhunter)
	}
	if target.DebuffExpires(magic_vulnerability any=1) Spell(curse_of_the_elements)
	if TalentPoints(grimoire_of_service_talent) Spell(service_felhunter)
	if TalentPoints(grimoire_of_sacrifice_talent) and BuffExpires(grimoire_of_sacrifice) unless pet.CreatureFamily(Felhunter) Spell(summon_felhunter)
	if Enemies() >2 
	{
		if not target.DebuffPresent(rain_of_fire) and not InFlightToTarget(rain_of_fire) Spell(rain_of_fire)
		if BuffPresent(fire_and_brimstone) and not target.DebuffPresent(immolate) Spell(immolate)
		if BurningEmbers() and BuffPresent(fire_and_brimstone) Spell(conflagrate)
		if BuffPresent(fire_and_brimstone) Spell(incinerate)
		if not target.DebuffPresent(immolate) Spell(immolate)
	}
	if Enemies() >1 focus.Spell(havoc)
	if BurningEmbers() if target.HealthPercent(less 20) Spell(shadowburn)
	if target.TicksRemain(immolate) <Ticks(immolate) /2 and target.DeadIn() >=5 Spell(immolate)
	if BurningEmbers() and {BuffStacks(backdraft) <3 or Level() <86 } and {BurningEmbers() >3.5 or BuffRemains(dark_soul) >CastTime(chaos_bolt) } and ManaPercent() <=80 Spell(chaos_bolt)
	Spell(conflagrate)
	Spell(incinerate)
	if BurningEmbers() >2 and ManaPercent() <10 Spell(chaos_bolt)
}
AddIcon mastery=3 help=offgcd
{
	if Enemies() >2 
	{
		if BurningEmbers() and BuffExpires(fire_and_brimstone) Spell(fire_and_brimstone)
	}
}
AddIcon mastery=3 help=aoe
{
	
	{
		Spell(summon_infernal)
	}
}
AddIcon mastery=3 help=cd
{
	 { Item(Trinket0Slot usable=1) Item(Trinket1Slot usable=1) } 
	Spell(blood_fury)
	Spell(dark_soul)
	if TalentPoints(grimoire_of_sacrifice_talent) Spell(grimoire_of_sacrifice)
	
	{
		Spell(summon_doomguard)
	}
	Spell(summon_doomguard)
}
]]