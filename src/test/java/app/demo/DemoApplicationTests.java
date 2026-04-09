package app.demo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import org.springframework.http.MediaType;

import app.api.controller.TestController;

@WebMvcTest(TestController.class)
class DemoApplicationTests {

	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private TestController testController;

	@BeforeEach
	void setUp(){
		mockMvc = MockMvcBuilders.standaloneSetup(testController).build();
	}

	@Test
	void contextLoads() throws Exception{
       mockMvc.perform(
		MockMvcRequestBuilders.post("/isTest")
		.contentType(MediaType.APPLICATION_JSON)
		.content("{\"message\":\"test text\"}")
	   )
	   .andExpect(MockMvcResultMatchers.status().isOk());

	}

}
