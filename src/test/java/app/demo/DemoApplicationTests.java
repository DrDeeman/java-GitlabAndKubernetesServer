package app.demo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import org.springframework.http.MediaType;

import app.api.controller.TestController;

@SpringBootTest
@ActiveProfiles("test")
class DemoApplicationTests {

	private MockMvc mockMvc;

	@Autowired
	private TestController testController;

	@BeforeEach
	void setUp(){
		mockMvc = MockMvcBuilders.standaloneSetup(testController).build();
	}

	@Test
    @Sql(scripts = {"classpath:sql/schema.sql"}, executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
	@Sql(scripts = {"classpath:sql/cleanup.sql"}, executionPhase = Sql.ExecutionPhase.AFTER_TEST_METHOD)
	void contextLoads() throws Exception{
       mockMvc.perform(
		MockMvcRequestBuilders.post("/isTest")
		.contentType(MediaType.APPLICATION_JSON)
		.content("{\"message\":\"test text\"}")
	   )
	   .andExpect(MockMvcResultMatchers.status().isOk());

	}

}
