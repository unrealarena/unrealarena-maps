// Shaders for *Radiant editors

// A solid surface that doesn't get rendered but blocks visibility checks.
// Usually used on the non-visible sides of regular brushes.
textures/common/caulk
{
	qer_editorimage textures/common/caulk

	surfaceparm nodraw
}

// Defines trigger areas.
textures/common/trigger
{
	qer_editorimage textures/common/trigger

	qer_nocarve
	qer_trans 0.5

	surfaceparm nodraw
}

// Defines playerclip areas.
textures/common/playerclip
{
	qer_editorimage textures/common/playerclip

	qer_trans 0.4

	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm playerclip
	surfaceparm trans
}
