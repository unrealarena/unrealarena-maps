// Shaders for *Radiant editors

// A solid surface that doesn't get rendered but blocks visibility checks.
// Usually used on the non-visible sides of regular brushes.
textures/common/caulk
{
	qer_editorimage textures/radiant/caulk

	surfaceparm nodraw
}

// Defines trigger areas.
textures/common/trigger
{
	qer_editorimage textures/radiant/trigger

	qer_nocarve
	qer_trans 0.5

	surfaceparm nodraw
}
