package funkin.ui.debug.charting;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * Available themes for the chart editor state.
 */
enum ChartEditorTheme
{
	Light;
	Dark;
}

/**
 * Static functions which handle building themed UI elements for a provided ChartEditorState.
 */
class ChartEditorThemeHandler
{
	// TODO: There's probably a better system of organization for these colors.
	// An enum of typedefs or something?
	// ================================
	static final BACKGROUND_COLOR_LIGHT:FlxColor = 0xFF673AB7;
	static final BACKGROUND_COLOR_DARK:FlxColor = 0xFF673AB7;

	// Color 1 of the grid pattern. Alternates with Color 2.
	static final GRID_COLOR_1_LIGHT:FlxColor = 0xFFE7E6E6;
	static final GRID_COLOR_1_DARK:FlxColor = 0xFF181919;

	// Color 2 of the grid pattern. Alternates with Color 1.
	static final GRID_COLOR_2_LIGHT:FlxColor = 0xFFD9D5D5;
	static final GRID_COLOR_2_DARK:FlxColor = 0xFF262A2A;

	// Vertical divider between characters.
	static final GRID_STRUMLINE_DIVIDER_COLOR_LIGHT:FlxColor = 0xFF000000;
	static final GRID_STRUMLINE_DIVIDER_COLOR_DARK:FlxColor = 0xFFC4C4C4;
	static final GRID_STRUMLINE_DIVIDER_WIDTH:Float = 2;

	// Horizontal divider between measures.
	static final GRID_MEASURE_DIVIDER_COLOR_LIGHT:FlxColor = 0xFF000000;
	static final GRID_MEASURE_DIVIDER_COLOR_DARK:FlxColor = 0xFFC4C4C4;
	static final GRID_MEASURE_DIVIDER_WIDTH:Float = 2;

	// Border on the square highlighting selected notes.
	static final SELECTION_SQUARE_BORDER_COLOR_LIGHT:FlxColor = 0xFF339933;
	static final SELECTION_SQUARE_BORDER_COLOR_DARK:FlxColor = 0xFF339933;
	static final SELECTION_SQUARE_BORDER_WIDTH:Int = 1;

	// Fill on the square highlighting selected notes.
	// Make sure this is transparent so you can see the notes underneath.
	static final SELECTION_SQUARE_FILL_COLOR_LIGHT:FlxColor = 0x4033FF33;
	static final SELECTION_SQUARE_FILL_COLOR_DARK:FlxColor = 0x4033FF33;

	// TODO: Un-hardcode these to be based on time signature.
	static final STEPS_PER_BEAT:Int = 4;
	static final BEATS_PER_MEASURE:Int = 4;

	public static function updateTheme(state:ChartEditorState):Void
	{
		updateBackground(state);
		updateGridBitmap(state);
		updateSelectionSquare(state);
	}

	static function updateBackground(state:ChartEditorState):Void
	{
		state.menuBG.color = switch (state.currentTheme)
		{
			case ChartEditorTheme.Light: BACKGROUND_COLOR_LIGHT;
			case ChartEditorTheme.Dark: BACKGROUND_COLOR_DARK;
			default: BACKGROUND_COLOR_LIGHT;
		}
	}

	/**
	 * Builds the checkerboard background image of the chart editor, and adds dividing lines to it.
	 * @param dark Whether to draw the grid in a dark color instead of a light one.
	 */
	static function updateGridBitmap(state:ChartEditorState):Void
	{
		var gridColor1:FlxColor = switch (state.currentTheme)
		{
			case Light: GRID_COLOR_1_LIGHT;
			case Dark: GRID_COLOR_1_DARK;
			default: GRID_COLOR_1_LIGHT;
		};

		var gridColor2:FlxColor = switch (state.currentTheme)
		{
			case Light: GRID_COLOR_2_LIGHT;
			case Dark: GRID_COLOR_2_DARK;
			default: GRID_COLOR_2_LIGHT;
		};

		// Draw the base grid.

		// 2 * (Strumline Size) + 1 grid squares wide, by (4 * quarter notes per measure) grid squares tall.
		// This gets reused to fill the screen.
		var gridWidth = ChartEditorState.GRID_SIZE * (ChartEditorState.STRUMLINE_SIZE * 2 + 1);
		var gridHeight = ChartEditorState.GRID_SIZE * (STEPS_PER_BEAT * BEATS_PER_MEASURE);
		state.gridBitmap = FlxGridOverlay.createGrid(ChartEditorState.GRID_SIZE, ChartEditorState.GRID_SIZE, gridWidth, gridHeight, true, gridColor1,
			gridColor2);

		// Draw dividers between the strumlines.

		var gridStrumlineDividerColor:FlxColor = switch (state.currentTheme)
		{
			case Light: GRID_STRUMLINE_DIVIDER_COLOR_LIGHT;
			case Dark: GRID_STRUMLINE_DIVIDER_COLOR_DARK;
			default: GRID_STRUMLINE_DIVIDER_COLOR_LIGHT;
		};

		// Divider at 1 * (Strumline Size)
		var dividerLineAX = ChartEditorState.GRID_SIZE * (ChartEditorState.STRUMLINE_SIZE) - (GRID_STRUMLINE_DIVIDER_WIDTH / 2);
		state.gridBitmap.fillRect(new Rectangle(dividerLineAX, 0, GRID_STRUMLINE_DIVIDER_WIDTH, state.gridBitmap.height), gridStrumlineDividerColor);
		// Divider at 2 * (Strumline Size)
		var dividerLineBX = ChartEditorState.GRID_SIZE * (ChartEditorState.STRUMLINE_SIZE * 2) - (GRID_STRUMLINE_DIVIDER_WIDTH / 2);
		state.gridBitmap.fillRect(new Rectangle(dividerLineBX, 0, GRID_STRUMLINE_DIVIDER_WIDTH, state.gridBitmap.height), gridStrumlineDividerColor);

		// Draw dividers between the measures.

		var gridMeasureDividerColor:FlxColor = switch (state.currentTheme)
		{
			case Light: GRID_MEASURE_DIVIDER_COLOR_LIGHT;
			case Dark: GRID_MEASURE_DIVIDER_COLOR_DARK;
			default: GRID_MEASURE_DIVIDER_COLOR_LIGHT;
		};

		// Divider at top
		state.gridBitmap.fillRect(new Rectangle(0, 0, state.gridBitmap.width, GRID_MEASURE_DIVIDER_WIDTH / 2), gridMeasureDividerColor);
		// Divider at bottom
		var dividerLineBY = state.gridBitmap.height - (GRID_MEASURE_DIVIDER_WIDTH / 2);
		state.gridBitmap.fillRect(new Rectangle(0, dividerLineBY, GRID_MEASURE_DIVIDER_WIDTH / 2, state.gridBitmap.height), gridMeasureDividerColor);
	}

	static function updateSelectionSquare(state:ChartEditorState):Void
	{
		var selectionSquareBorderColor:FlxColor = switch (state.currentTheme)
		{
			case Light: SELECTION_SQUARE_BORDER_COLOR_LIGHT;
			case Dark: SELECTION_SQUARE_BORDER_COLOR_DARK;
			default: SELECTION_SQUARE_BORDER_COLOR_LIGHT;
		};

		var selectionSquareFillColor:FlxColor = switch (state.currentTheme)
		{
			case Light: SELECTION_SQUARE_FILL_COLOR_LIGHT;
			case Dark: SELECTION_SQUARE_FILL_COLOR_DARK;
			default: SELECTION_SQUARE_FILL_COLOR_LIGHT;
		};

		state.selectionSquareBitmap = new BitmapData(ChartEditorState.GRID_SIZE, ChartEditorState.GRID_SIZE, true);

		state.selectionSquareBitmap.fillRect(new Rectangle(0, 0, ChartEditorState.GRID_SIZE, ChartEditorState.GRID_SIZE), selectionSquareBorderColor);
		state.selectionSquareBitmap.fillRect(new Rectangle(SELECTION_SQUARE_BORDER_WIDTH, SELECTION_SQUARE_BORDER_WIDTH,
			ChartEditorState.GRID_SIZE - (SELECTION_SQUARE_BORDER_WIDTH * 2), ChartEditorState.GRID_SIZE - (SELECTION_SQUARE_BORDER_WIDTH * 2)),
			selectionSquareFillColor);

		state.selectionBoxSprite = new FlxSliceSprite(state.selectionSquareBitmap,
			new FlxRect(SELECTION_SQUARE_BORDER_WIDTH
				+ 4, SELECTION_SQUARE_BORDER_WIDTH
				+ 4,
				ChartEditorState.GRID_SIZE
				- (2 * SELECTION_SQUARE_BORDER_WIDTH + 8), ChartEditorState.GRID_SIZE
				- (2 * SELECTION_SQUARE_BORDER_WIDTH + 8)),
			32, 32);
	}
}
