/*
	This is the webpack config for building FormBuilder, the FormBuilder.min.js gets created
	in the ./dist folder inside this directory and in ../source/carehub/main/default/staticresources
	to be available for deployment on an org
*/
const path = require("path");

var config = {
	mode: "production",
	entry: {
		FormBuilder: path.resolve(__dirname, "src/FormBuilder.ts")
	},
	output: {
		path: path.resolve(__dirname, "dist"),
		filename: "[name].min.js"
	},
	resolve: {
		extensions: [".ts", ".tsx", ".js", ".jsx"],
		alias: {
			"@": path.resolve(__dirname, "src")
		}
	},
	module: {
		rules: [
			{
				test: /\.(tsx|ts|jsx|js)$/,
				include: path.resolve(__dirname, "src"),
				exclude: /node_modules/,
				use: [
					{
						loader: "babel-loader",
						options: {
							presets: [
								[
									"@babel/preset-env",
									{
										targets: "defaults"
									}
								],
								"@babel/preset-react",
								"@babel/preset-typescript"
							]
						}
					}
				]
			},
			{
				test: /\.css$/,
				use: ["style-loader", "css-loader"]
			}
		]
	},
	optimization: {
		minimize: true
	},
	externals: {
		react: "React",
		"react-dom/client": "ReactDOM",
		"survey-core": "Survey",
		"survey-react-ui": "SurveyReact",
		"survey-creator-core": "SurveyCreatorCore",
		"survey-creator-react": "SurveyCreator",
	}
};

var configLocal = Object.assign({}, config, {
	output: {
		path: path.resolve(__dirname, "dist"),
		filename: "[name].min.js"
	}
});

var configSF = Object.assign({}, config, {
	output: {
		path: path.resolve(__dirname, "../source/carehub/main/default/staticresources"),
		filename: "[name].min.js"
	}
});

module.exports = [configLocal, configSF];
